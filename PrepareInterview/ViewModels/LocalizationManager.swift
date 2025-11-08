//
//  LocalizationManager.swift
//  InterviewPrep
//
//  Created on 2024
//

import Foundation

struct LocalizedStrings {
    let language: AppLanguage
    
    // Navigation & General
    var appTitle: String {
        switch language {
        case .turkish: return "Mülakat Hazırlık"
        case .english: return "Interview Prep"
        case .spanish: return "Preparación para Entrevistas"
        case .french: return "Préparation aux Entretiens"
        case .russian: return "Подготовка к Интервью"
        case .chinese: return "面试准备"
        }
    }
    
    var questions: String {
        switch language {
        case .turkish: return "soru"
        case .english: return "questions"
        case .spanish: return "preguntas"
        case .french: return "questions"
        case .russian: return "вопросы"
        case .chinese: return "问题"
        }
    }
    
    var question: String {
        switch language {
        case .turkish: return "Soru:"
        case .english: return "Question:"
        case .spanish: return "Pregunta:"
        case .french: return "Question:"
        case .russian: return "Вопрос:"
        case .chinese: return "问题："
        }
    }
    
    var answer: String {
        switch language {
        case .turkish: return "Cevap:"
        case .english: return "Answer:"
        case .spanish: return "Respuesta:"
        case .french: return "Réponse:"
        case .russian: return "Ответ:"
        case .chinese: return "答案："
        }
    }
    
    var explanation: String {
        switch language {
        case .turkish: return "Açıklama:"
        case .english: return "Explanation:"
        case .spanish: return "Explicación:"
        case .french: return "Explication:"
        case .russian: return "Объяснение:"
        case .chinese: return "解释："
        }
    }
    
    var showAnswer: String {
        switch language {
        case .turkish: return "Cevabı Göster"
        case .english: return "Show Answer"
        case .spanish: return "Mostrar Respuesta"
        case .french: return "Afficher la Réponse"
        case .russian: return "Показать Ответ"
        case .chinese: return "显示答案"
        }
    }
    
    var hideAnswer: String {
        switch language {
        case .turkish: return "Cevabı Gizle"
        case .english: return "Hide Answer"
        case .spanish: return "Ocultar Respuesta"
        case .french: return "Masquer la Réponse"
        case .russian: return "Скрыть Ответ"
        case .chinese: return "隐藏答案"
        }
    }
    
    var previous: String {
        switch language {
        case .turkish: return "Önceki"
        case .english: return "Previous"
        case .spanish: return "Anterior"
        case .french: return "Précédent"
        case .russian: return "Предыдущий"
        case .chinese: return "上一个"
        }
    }
    
    var next: String {
        switch language {
        case .turkish: return "Sonraki"
        case .english: return "Next"
        case .spanish: return "Siguiente"
        case .french: return "Suivant"
        case .russian: return "Следующий"
        case .chinese: return "下一个"
        }
    }
    
    var close: String {
        switch language {
        case .turkish: return "Kapat"
        case .english: return "Close"
        case .spanish: return "Cerrar"
        case .french: return "Fermer"
        case .russian: return "Закрыть"
        case .chinese: return "关闭"
        }
    }
    
    var retry: String {
        switch language {
        case .turkish: return "Tekrar Dene"
        case .english: return "Retry"
        case .spanish: return "Reintentar"
        case .french: return "Réessayer"
        case .russian: return "Повторить"
        case .chinese: return "重试"
        }
    }
    
    var loading: String {
        switch language {
        case .turkish: return "Yükleniyor..."
        case .english: return "Loading..."
        case .spanish: return "Cargando..."
        case .french: return "Chargement..."
        case .russian: return "Загрузка..."
        case .chinese: return "加载中..."
        }
    }
    
    var errorLoading: String {
        switch language {
        case .turkish: return "JSON dosyası yüklenemedi"
        case .english: return "Failed to load JSON file"
        case .spanish: return "Error al cargar el archivo JSON"
        case .french: return "Échec du chargement du fichier JSON"
        case .russian: return "Не удалось загрузить файл JSON"
        case .chinese: return "加载JSON文件失败"
        }
    }
    
    // Menu Tabs
    var questionsTab: String {
        switch language {
        case .turkish: return "Sorular"
        case .english: return "Questions"
        case .spanish: return "Preguntas"
        case .french: return "Questions"
        case .russian: return "Вопросы"
        case .chinese: return "问题"
        }
    }
    
    var notesTab: String {
        switch language {
        case .turkish: return "Ders Notları"
        case .english: return "Notes"
        case .spanish: return "Notas"
        case .french: return "Notes"
        case .russian: return "Заметки"
        case .chinese: return "笔记"
        }
    }
    
    var gameTab: String {
        switch language {
        case .turkish: return "Oyun"
        case .english: return "Game"
        case .spanish: return "Juego"
        case .french: return "Jeu"
        case .russian: return "Игра"
        case .chinese: return "游戏"
        }
    }
    
    var page: String {
        switch language {
        case .turkish: return "Sayfa"
        case .english: return "Page"
        case .spanish: return "Página"
        case .french: return "Page"
        case .russian: return "Страница"
        case .chinese: return "页面"
        }
    }
    
    // Game Strings
    var gameTitle: String {
        switch language {
        case .turkish: return "Bilgi Yarışması"
        case .english: return "Quiz Game"
        case .spanish: return "Juego de Preguntas"
        case .french: return "Jeu de Quiz"
        case .russian: return "Викторина"
        case .chinese: return "测验游戏"
        }
    }
    
    var gameDescription: String {
        switch language {
        case .turkish: return "Soruları cevaplayın ve puan kazanın! Her doğru cevap 10 puan değerinde."
        case .english: return "Answer questions and earn points! Each correct answer is worth 10 points."
        case .spanish: return "¡Responde preguntas y gana puntos! Cada respuesta correcta vale 10 puntos."
        case .french: return "Répondez aux questions et gagnez des points! Chaque bonne réponse vaut 10 points."
        case .russian: return "Отвечайте на вопросы и зарабатывайте очки! Каждый правильный ответ стоит 10 очков."
        case .chinese: return "回答问题并获得积分！每个正确答案值10分。"
        }
    }
    
    var startGame: String {
        switch language {
        case .turkish: return "Oyunu Başlat"
        case .english: return "Start Game"
        case .spanish: return "Comenzar Juego"
        case .french: return "Commencer le Jeu"
        case .russian: return "Начать игру"
        case .chinese: return "开始游戏"
        }
    }
    
    var bestScore: String {
        switch language {
        case .turkish: return "En İyi Skor"
        case .english: return "Best Score"
        case .spanish: return "Mejor Puntuación"
        case .french: return "Meilleur Score"
        case .russian: return "Лучший счет"
        case .chinese: return "最佳分数"
        }
    }
    
    var points: String {
        switch language {
        case .turkish: return "Puan"
        case .english: return "Points"
        case .spanish: return "Puntos"
        case .french: return "Points"
        case .russian: return "Очки"
        case .chinese: return "积分"
        }
    }
    
    var gameOver: String {
        switch language {
        case .turkish: return "Oyun Bitti"
        case .english: return "Game Over"
        case .spanish: return "Juego Terminado"
        case .french: return "Jeu Terminé"
        case .russian: return "Игра окончена"
        case .chinese: return "游戏结束"
        }
    }
    
    var yourScore: String {
        switch language {
        case .turkish: return "Skorunuz"
        case .english: return "Your Score"
        case .spanish: return "Tu Puntuación"
        case .french: return "Votre Score"
        case .russian: return "Ваш счет"
        case .chinese: return "您的分数"
        }
    }
    
    var playAgain: String {
        switch language {
        case .turkish: return "Tekrar Oyna"
        case .english: return "Play Again"
        case .spanish: return "Jugar de Nuevo"
        case .french: return "Rejouer"
        case .russian: return "Играть снова"
        case .chinese: return "再玩一次"
        }
    }
    
    var newRecord: String {
        switch language {
        case .turkish: return "Yeni Rekor!"
        case .english: return "New Record!"
        case .spanish: return "¡Nuevo Récord!"
        case .french: return "Nouveau Record!"
        case .russian: return "Новый рекорд!"
        case .chinese: return "新纪录！"
        }
    }
    
    // Categories
    var lowLevelDesign: String {
        switch language {
        case .turkish: return "Düşük Seviye Tasarım"
        case .english: return "Low Level Design"
        case .spanish: return "Diseño de Bajo Nivel"
        case .french: return "Conception de Bas Niveau"
        case .russian: return "Низкоуровневое Проектирование"
        case .chinese: return "低级设计"
        }
    }
    
    var highLevelDesign: String {
        switch language {
        case .turkish: return "Yüksek Seviye Tasarım"
        case .english: return "High Level Design"
        case .spanish: return "Diseño de Alto Nivel"
        case .french: return "Conception de Haut Niveau"
        case .russian: return "Высокоуровневое Проектирование"
        case .chinese: return "高级设计"
        }
    }
    
    // Difficulty levels
    func difficulty(_ level: String) -> String {
        switch level.lowercased() {
        case "kolay", "easy":
            switch language {
            case .turkish: return "Kolay"
            case .english: return "Easy"
            case .spanish: return "Fácil"
            case .french: return "Facile"
            case .russian: return "Легкий"
            case .chinese: return "简单"
            }
        case "orta", "medium":
            switch language {
            case .turkish: return "Orta"
            case .english: return "Medium"
            case .spanish: return "Medio"
            case .french: return "Moyen"
            case .russian: return "Средний"
            case .chinese: return "中等"
            }
        case "zor", "hard":
            switch language {
            case .turkish: return "Zor"
            case .english: return "Hard"
            case .spanish: return "Difícil"
            case .french: return "Difficile"
            case .russian: return "Сложный"
            case .chinese: return "困难"
            }
        default:
            return level
        }
    }
}

