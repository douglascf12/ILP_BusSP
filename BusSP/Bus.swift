//
//  Bus.swift
//  BusSP
//
//  Created by Douglas Cardoso Ferreira on 16/07/20.
//  Copyright © 2020 Douglas Cardoso. All rights reserved.
//

import Foundation

struct Bus: Codable {
    var cl: Int // Código identificador da linha
    var lc: Bool // Indica se a linha é circular
    var lt: String // Primeira parte do letreiro númerico da linha
    var sl: Int // Sentido da linha (1 - Terminal Principal para Terminal Secundário e 2 - Terminal Secundário para Terminal Principal)
    var tl: Int // Segunda parte do letreiro númerico da linha
    var tp: String // Letreiro descritivo da linha do Terminal Principal para Terminal Secundário
    var ts: String // Letreiro descritivo da linha do Terminal Secundário para Terminal Principal
}
