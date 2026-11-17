# Security model and resource limits

Diagram text crosses into JavaScript as a WebKit argument, not as executable
script. The page loads local package resources with a restrictive Content
Security Policy. A WebKit content rule blocks HTTP and HTTPS requests, and
navigation away from the bundled page is rejected. Failure to install the rule
fails rendering. Mermaid is configured with `securityLevel: 'strict'` and
limits on text and edges. These are defense-in-depth measures, not a general
sandbox or a guarantee that arbitrary hostile diagrams are safe.

Sources are limited to 50,000 Swift characters. The queue wait has a 60-second
deadline. Content-rule compilation, page load, and PDF creation each have a
30-second deadline; the JavaScript call has a 20-second deadline. These are
individual asynchronous operation deadlines, not a 20-second end-to-end limit.
They do not limit all CPU or memory use, and cancellation of a running WebKit
operation may not complete until its deadline. The cache limits entry count,
not total memory. An app accepting untrusted diagrams should apply its own
input and resource policies.

Do not treat generated PDF or SVG content as a sanitization boundary for use
outside this renderer. Report suspected bypasses privately as described in
[SECURITY.md](../SECURITY.md).
