cask "sentinel" do
  version "0.1.0"
  sha256 "2fbbfe5b6cfe66fa7ab3701f4f2da504867d4be278c6d50bbd1d620ecdfc0927"

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
