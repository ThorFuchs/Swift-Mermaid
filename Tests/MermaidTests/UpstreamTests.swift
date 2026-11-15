import CryptoKit
import Foundation
@testable import Mermaid
import Testing

/// The bundled files are exactly the ones recorded in Upstream.json, at the version the code names.
@Suite struct Upstream {
    static let root = URL(filePath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()

    @Test func bundledFilesMatchTheManifest() throws {
        let manifest = try #require(JSONSerialization.jsonObject(with: Data(contentsOf: Self.root.appending(path: "Upstream.json"))) as? [String: Any])
        #expect(manifest["version"] as? String == MermaidRenderer.mermaidVersion)
        let files = try #require(manifest["files"] as? [String: String])
        let dir = Self.root.appending(path: "Sources/Mermaid/Resources/mermaid")
        var onDisk: Set<String> = []
        for case let path as String in FileManager.default.enumerator(atPath: dir.path)! {
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: dir.appending(path: path).path, isDirectory: &isDirectory), !isDirectory.boolValue { onDisk.insert(path) }
        }
        #expect(onDisk == Set(files.keys))
        for (path, sha) in files {
            let digest = SHA256.hash(data: try Data(contentsOf: dir.appending(path: path))).map { String(format: "%02x", $0) }.joined()
            #expect(digest == sha, "\(path)")
        }
    }
}
