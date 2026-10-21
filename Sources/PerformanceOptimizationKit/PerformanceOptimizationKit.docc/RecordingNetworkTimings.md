# Recording Network Timings

Find out where the time of each request goes, and what the package records about a request.

## Overview

`NetworkMetricsCollector` receives the `URLSessionTaskMetrics` of every task it is the
delegate of and keeps a `NetworkTiming` for each one: the phases of the request (DNS lookup,
connection, TLS, sending, waiting for the first byte, receiving), the status code, the protocol,
whether the connection was reused and whether the answer came from the cache.

```swift
let collector = NetworkMetricsCollector(redaction: URLRedaction(allowedQueryParameters: ["page"]))
let session = URLSession(configuration: .default, delegate: collector, delegateQueue: nil)

let (data, _) = try await session.data(from: URL(string: "https://api.example.com/v1/users/48213/orders?page=2&token=abc")!)
collector.timings.last?.url      // "https://api.example.com/v1/users/:id/orders?page=2"
collector.timings.last?.phases.waiting
```

A long `waiting` phase is time the server spent on the request; long `connect` and
`secureConnection` phases on every request mean that connections are not reused.

## What is recorded and what is never recorded

Timings are meant to be logged or sent with a report, so they hold as little about the request
as the measurement needs.

- **Recorded:** the redacted URL, the HTTP method and the protocol name when they are short
  plain words (otherwise `nil`), the status code, the timestamps of the phases and the size of
  the response body in bytes.
- **Never recorded:** request and response headers (including `Authorization` and cookies),
  request and response bodies, the user name and password of the URL, its fragment, and the
  query, except for the parameters you allow.

The collector does not read headers or bodies at all, so there is no body parser that could
misread one. `URLRedaction` handles the URL. Its rule is that anything it does not fully
understand is hidden:

- Path segments that look like identifiers (numbers, UUIDs, e-mail addresses, runs of six or
  more digits, card numbers, IBANs, tokens) become `:id`.
- The segment after a name such as `token`, `password`, `pin` or `api_key` becomes `:id`.
- A segment that holds such a name together with more, such as `token-hunter22`, `pin_4831` or
  `passwordhunter2`, becomes `:id`, because the rest can be the secret, and so does the segment
  after it.
- A segment that is not plain ASCII after percent-decoding becomes `:id`, and so does the
  segment after it. This covers look-alike letters from other scripts, invisible format
  characters, combining marks and non-Latin names such as `Şifre`: they are hidden on purpose,
  even when they are harmless.
- A path that servers could read in different ways (with `.` or `..` segments, a `;`, a
  backslash, a double percent-encoding or an encoded `/`, `?`, `#` or `.`) is recorded as
  scheme and host only, and so is a URL whose path or query is longer than the documented caps.
- A host that names a secret (`myapp://pin/4831`) keeps only scheme and host; a host that is
  not a plain DNS name or IP address (an IPv6 address with a zone such as `%25en0` included),
  looks like an identifier, or has a label that holds a secret name together with more
  (`myapp://pin-4831`, and also `oauth2.example.com`) keeps only the scheme.
- Query parameters are dropped unless you name them in
  `URLRedaction/allowedQueryParameters`. Even then a value is kept only when it is short and
  plain; a value with symbols, an identifier or a secret name becomes `<redacted>`. Names of
  secrets and names that are not plain ASCII cannot be allowed.

## What it does not find

Redaction is a safety net, not a guarantee. It cannot know that an ordinary-looking word is
secret: in `https://api.example.com/v1/invite/sunflower`, `sunflower` stays in the timing even
if it is an invitation code. The same goes for a short code of letters and a few digits,
such as `ab12cd`, that does not follow a secret name, and for a token of 16 to 31 letters
without digits, such as `AbCdEfGhIjKlMnOpQrSt`, which cannot be told apart from a long word.
A short secret name such as `pin`, `key` or `sid` is only recognized inside a segment when a
separator follows it (`pin_4831`), because it is also part of ordinary words (`ping`,
`keyboard`): `pin4831` is kept. In a host, `.` separates labels, so in `myapp://pin.ab12cd` the
label `pin` names a secret and the host is kept as it is. Keep secrets out of URLs; send them in
headers or in the body, which the collector never records. If even the paths of your API carry
personal data, use `URLRedaction(recordsHostOnly: true)`.

## Limits

Redaction runs on URLs the app does not control, so its cost is bounded: it looks at no more
than `URLRedaction/maximumPathSegments` segments, `URLRedaction/maximumQueryParameters`
parameters and `URLRedaction/maximumComponentBytes` bytes of path or query, and returns at
most `URLRedaction/maximumLength` characters. The tests redact URLs of 1 MB in each of these
shapes in well under a second, on a thread with a 512 KiB stack. The collector keeps the newest
`capacity` timings; the stream from `NetworkMetricsCollector/updates()` keeps the 64 newest
when its reader falls behind.
