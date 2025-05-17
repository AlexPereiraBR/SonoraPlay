//
//  PlaybackMode.swift
//  SonoraPlay
//
//  Created by Aleksandr Shchukin on 17/05/25.
//

import Foundation

enum PlaybackMode: CaseIterable {
    case normal          // По очереди
    case repeatOne       // Повтор одного
    case repeatAll       // Повтор всех
    case shuffle         // Перемешать
}
