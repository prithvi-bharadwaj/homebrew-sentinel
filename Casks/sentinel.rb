cask "sentinel" do
  version "0.1.0"
  sha256 "b49589d52c1705ce802e00250ce5c4bc6e92e0503ca677aee1401abe6f1d7e52"

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
