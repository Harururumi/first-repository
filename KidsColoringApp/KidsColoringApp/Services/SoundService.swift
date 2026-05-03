import AVFoundation
import AudioToolbox

enum AppSound: CaseIterable {
    case colorSplash
    case celebration
    case pageSelect
    case undo

    var systemSoundId: SystemSoundID {
        switch self {
        case .colorSplash: return 1104
        case .celebration: return 1028
        case .pageSelect: return 1057
        case .undo: return 1053
        }
    }
}

class SoundService {
    static let shared = SoundService()
    private var isSoundEnabled = true

    private init() {}

    func setup() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func play(_ sound: AppSound) {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(sound.systemSoundId)
    }

    func toggleSound() {
        isSoundEnabled.toggle()
    }
}
