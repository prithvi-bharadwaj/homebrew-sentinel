cask "sentinel" do
  version "0.1.0"
  sha256 "c2379c697c3373c86180788f33ff3b9dc8c8d71461c07163e2d706b2d761a3a6"

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
