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
  more digits, card numbers, IBANs, tokens) become `:id`. An identifier also hides the segment
  after it by the rules below when it holds a secret name or is not a plain name, such as
  `token123456`, `4831.pin`, `t@ken`, `p!n123456` or `张伟@example.cn`. Only an e-mail address
  whose parts are plain names without a secret name (`jane.doe@example.org`) and a number such
  as `+905551234567` or `123-45-6789` keep the segment after them.
- The segment after a name such as `token`, `password`, `pin` or `api_key` becomes `:id`.
- A segment that holds such a name together with more, such as `token-hunter22`, `pin_4831`,
  `pin4831` or `passwordhunter2`, becomes `:id`, because the rest can be the secret, and so does
  the segment after it.
- A segment that is not a plain ASCII name (letters, digits, `_`, `-`, `.` and spaces) after
  percent-decoding becomes `:id`, and so does the segment after it. This covers other symbols
  (`c++`, `t!ken`, `p@ssword`), look-alike letters from other scripts, a single letter, mark or
  number from another script inside a word (`tͦken`, `passw〇rd`, `piꞏn`), invisible format
  characters, control characters, combining marks and non-Latin names such as `Şifre`: they are
  hidden on purpose, even when they are harmless.
- A path that servers could read in different ways (with `.` or `..` segments, a `;`, a
  backslash, a double percent-encoding or an encoded `/`, `?`, `#` or `.`) is recorded as
  scheme and host only, and so is a URL whose path or query is longer than the documented caps.
- A host is read like a name, its `.` like the other separators. A host that names a secret
  (`myapp://pin/4831`) keeps only scheme and host; a host that is not a plain DNS name or IP
  address (an IPv6 address with a zone such as `%25en0` included), has a label that looks like
  an identifier, or holds a secret name together with more, also in another label
  (`myapp://pin-4831`, `myapp://pin.ab12cd`, and also `token.example.com` and
  `oauth2.example.com`), keeps only the scheme.
- Query parameters are dropped unless you name them in
  `URLRedaction/allowedQueryParameters`. Even then a value is kept only when it is short and
  plain; a value with symbols, an identifier or a secret name becomes `<redacted>`. A value
  with commas is read as a whole, its commas as spaces, and each part is checked for an
  identifier, so `name,token`, `pass,word`, `4111,1111,1111,1111` and `name,deadbeefcafebabe`
  become `<redacted>` while `name,asc` is kept. Names of secrets and
  names that are not plain ASCII cannot be allowed.

## What it does not find

Redaction is a safety net, not a guarantee. It cannot know that an ordinary-looking word is
secret: in `https://api.example.com/v1/invite/sunflower`, `sunflower` stays in the timing even
if it is an invitation code. The same goes for a short code of letters and a few digits,
such as `ab12cd`, that does not follow a secret name, and for a token of 16 to 31 letters
without digits, such as `AbCdEfGhIjKlMnOpQrSt`, which cannot be told apart from a long word.
A short secret name such as `pin`, `key` or `sid` is also part of ordinary words (`ping`,
`keyboard`), so inside a segment it is only recognized with a separator (`pin_4831`) or next to
a digit, at either end of the segment or in the middle (`pin4831`, `4831pin`, `mypin4831`), also
when a separator splits the name itself (`p.in4831`, `p-i-n-4831`): `pinabcd` and `mypinabc`
are kept, and `keyboard2` is hidden. A short name at the end of a longer word whose code
follows after a separator, such as `mypin_4831`, is not recognized. Keep secrets out of URLs;
send them in headers or in the body, which the collector never records.
If even the paths of your API carry personal data, use `URLRedaction(recordsHostOnly: true)`.

## Limits

Redaction runs on URLs the app does not control, so its cost is bounded: it looks at no more
than `URLRedaction/maximumPathSegments` segments, `URLRedaction/maximumQueryParameters`
parameters and `URLRedaction/maximumComponentBytes` bytes of path or query, and returns at
most `URLRedaction/maximumLength` characters. The tests redact URLs of 1 MB in each of these
shapes in well under a second, on a thread with a 512 KiB stack. They also redact the slowest
URLs within the caps, in which every segment or allowed value is read (63 segments such as
`1-1-…-1`, or 60 values such as `a,1,a,1,…`), and check in an optimized build that this takes
under a second per MB and at most 15 times as long as a pass that only decodes each segment or
parameter and looks it up in a set. The collector keeps the newest
`capacity` timings; the stream from `NetworkMetricsCollector/updates()` keeps the 64 newest
when its reader falls behind.
