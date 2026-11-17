// SPDX-License-Identifier: Apache-2.0
import Testing

// WebKit startup is resource-intensive on a cold simulator. Serialize the
// WebKit-dependent suites relative to one another, while retaining any
// concurrency exercised inside individual tests.
@Suite(.serialized) enum WebKitTestSuite {}
