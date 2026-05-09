cask "sentinel" do
  version "0.1.0"
  sha256 "9248a8bcc826f485409f3479f5a462636ec4e1618f51505a2964e34b536310b7"

  url "https://github.com/prithvi-bharadwaj/homebrew-sentinel/releases/download/v#{version}/Sentinel-#{version}.dmg"
  name "Sentinel"
  desc "Lock keyboard, mouse, and trackpad while your Mac stays awake"
  homepage "https://github.com/prithvi-bharadwaj/homebrew-sentinel"

  depends_on macos: ">= :sonoma"

  app "Sentinel.app"

  zap trash: [
    "~/Library/Preferences/org.localhost.sentinel.plist",
    "~/Library/Application Support/Sentinel",
  ]
end
