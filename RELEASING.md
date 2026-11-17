# Releasing

1. Update the changelog and verify the bundled version, hashes, license and
   notice. Check the Mermaid release notes and wait at least two weeks after
   upstream publication before adopting an update.
2. Run the checks in [testing](Documentation/TESTING.md), including a visual
   review of the sample PDFs in both themes. Investigate any failures.
3. Ensure CI passes on the release commit and the README requirements and
   supported-platform claims match the evidence.
4. Commit the release changes, create a version tag on that commit, and publish
   release notes that include user-visible changes and the Mermaid version.

To update Mermaid, run `Scripts/update-upstream.sh <exact-version>`, follow its
instructions, and review the resulting diff. The script reports the upstream
publication date; it does not enforce the two-week waiting period.
