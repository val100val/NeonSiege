import SpriteKit
import AVFoundation

enum SFX: String, CaseIterable {
    case pulse = "sfx_pulse.wav"
    case cryo = "sfx_cryo.wav"
    case arc = "sfx_arc.wav"
    case rail = "sfx_rail.wav"
    case die = "sfx_die.wav"
    case place = "sfx_place.wav"
    case upgrade = "sfx_upgrade.wav"
    case sell = "sfx_sell.wav"
    case blocked = "sfx_blocked.wav"
    case stolen = "sfx_stolen.wav"
    case rescued = "sfx_rescued.wav"
    case wave = "sfx_wave.wav"
    case teleport = "sfx_teleport.wav"
    case win = "sfx_win.wav"
    case lose = "sfx_lose.wav"
    case tap = "sfx_tap.wav"
}

/// Central sound manager: low-latency SFX via SKAction, looping music via AVAudioPlayer.
final class Sound {
    static let shared = Sound()

    private var actions: [SFX: SKAction] = [:]
    private var lastPlayed: [SFX: TimeInterval] = [:]
    private var musicPlayer: AVAudioPlayer?

    private(set) var isEnabled: Bool

    private init() {
        isEnabled = UserDefaults.standard.object(forKey: "neonsiege.sound") as? Bool ?? true
        #if os(iOS)
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        #endif
        for sfx in SFX.allCases {
            let name = (sfx.rawValue as NSString).deletingPathExtension
            // Only preload files that actually exist so a missing file can never crash.
            if Bundle.main.url(forResource: name, withExtension: "wav") != nil {
                actions[sfx] = SKAction.playSoundFileNamed(sfx.rawValue, waitForCompletion: false)
            }
        }
    }

    func play(_ sfx: SFX, on node: SKNode) {
        guard isEnabled, let action = actions[sfx] else { return }
        let now = CACurrentMediaTime()
        if let last = lastPlayed[sfx], now - last < minInterval(sfx) { return }
        lastPlayed[sfx] = now
        node.run(action)
    }

    /// Rate limits so rapid-fire towers don't spam the mixer.
    private func minInterval(_ sfx: SFX) -> TimeInterval {
        switch sfx {
        case .pulse: return 0.08
        case .cryo, .arc, .rail: return 0.10
        case .die: return 0.06
        case .teleport: return 0.15
        default: return 0.02
        }
    }

    func startMusic() {
        if let player = musicPlayer {
            if isEnabled && !player.isPlaying { player.play() }
            return
        }
        guard let url = Bundle.main.url(forResource: "music_loop", withExtension: "wav") else { return }
        musicPlayer = try? AVAudioPlayer(contentsOf: url)
        musicPlayer?.numberOfLoops = -1
        musicPlayer?.volume = 0.28
        if isEnabled { musicPlayer?.play() }
    }

    func toggle() {
        isEnabled.toggle()
        UserDefaults.standard.set(isEnabled, forKey: "neonsiege.sound")
        if isEnabled {
            musicPlayer?.play()
        } else {
            musicPlayer?.pause()
        }
    }
}
