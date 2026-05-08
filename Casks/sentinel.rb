cask "sentinel" do
  version "0.1.0"
  sha256 "77f5d695725edc45b2edcd27c46455366579afa9407a0a980a027846bc320ea3"

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
