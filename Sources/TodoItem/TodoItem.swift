import Foundation
import UIKit

// MARK: - TodoItem ext. for Equatable

extension TodoItem {
    public static  func == (lhs: TodoItem, rhs: TodoItem) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - TodoItem

public struct TodoItem: Equatable {

    // MARK: - TodoItem Constants

    enum Constants {
        static let separatorCSV = ";"
        static let newlineCSV = "\n"
        static let specialSymbolForCSV = "\u{1}"
    }

    // MARK: - Keys enum

    public enum Keys: Int, CaseIterable {

        case keyId = 0
        case keyText
        case keyDeadline
        case keyIsDone
        case hexCode
        case keyPriority
        case keyDateCreated
        case keyDateChanged
        case keyUpdatedID

        public var description: String {
            switch self {
            case .keyId:
                return "id"
            case .keyText:
                return "text"
            case .keyDeadline:
                return "deadline"
            case .keyIsDone:
                return "isDone"
            case .hexCode:
                return "hexCode"
            case .keyPriority:
                return "priority"//priority
            case .keyDateCreated:
                return "dateCreated"
            case .keyDateChanged:
                return "dateChanged"
            case .keyUpdatedID:
                return "updatedID"
            }
        }
    }

    // MARK: - Priority enum

    public enum Priority: String {
        case low
        case basic //basic
        case important //import
        public var description: String {
            switch self {
            case .low:
                return "low"
            case .important:
                return "important"
            default:
                return "basic"
            }
        }
    }

    // MARK: - Properties

    public let id: String
    public let text: String
    public let deadline: Date?
    public var isDone: Bool
    public let hexCode: String?
    public let priority: Priority
    public let dateCreated: Date
    public var dateChanged: Date?
    public var updatedID: String

    // MARK: - Initializer

    public init(
        id: String = UUID().uuidString,
        text: String,
        deadline: Date? = nil,
        isDone: Bool = false,
        hexCode: String? = nil,
        priority: Priority,
        dateCreated: Date = Date(),
        dateChanged: Date? = nil,
        updatedID: String
    ) {
        self.id = id
        self.text = text
        self.deadline = deadline
        self.isDone = isDone
        self.hexCode = hexCode
        self.priority = priority
        self.dateCreated = dateCreated
        self.dateChanged = dateChanged
        self.updatedID = updatedID
    }
 
    public mutating func setDone(flag: Bool){
          self.isDone = flag
      }
    public mutating func setDate(date: Date){
          self.dateChanged = date
      }
    public mutating func setUpdatedID(){
          self.updatedID = UIDevice.current.identifierForVendor!.uuidString
      }
}

// MARK: - TodoItem Extenison

public extension TodoItem {

    // MARK: - CSV

    var csv: Any {

        var result: String =
        "\(id)\(Constants.separatorCSV)\(text.replacingOccurrences(of: Constants.separatorCSV, with: Constants.specialSymbolForCSV))"
        result += Constants.separatorCSV
        if deadline != nil {
            result += String(Int(dateCreated.timeIntervalSince1970))
        }

        result += Constants.separatorCSV + String(isDone)
        result += Constants.separatorCSV
        if hexCode != nil {
            result += Constants.separatorCSV + "\(hexCode)"
        }
        result += Constants.separatorCSV

        if priority != .basic {
            result += String(priority.rawValue)
        }

        result += Constants.separatorCSV + String(Int(dateCreated.timeIntervalSince1970))
        result += Constants.separatorCSV
        if dateChanged != nil {
            result += String(Int(dateCreated.timeIntervalSince1970))
        }
        return result
    }

    // MARK: - CSV parsing

    static func parse(csv: Any) -> TodoItem? {

        guard let object = csv as? String else {
            return nil
        }

        let columns = object.components(separatedBy: Constants.separatorCSV)
            .map({$0.replacingOccurrences(of: Constants.specialSymbolForCSV,
                                          with: Constants.separatorCSV)})

        let id = columns[Keys.keyId.rawValue]
        let text = columns[Keys.keyText.rawValue]

        guard let dateCreated = TimeInterval(columns[Keys.keyDateCreated.rawValue])
            .flatMap({ Date(timeIntervalSince1970: $0) }),
              let isDone = Bool(columns[Keys.keyIsDone.rawValue])
        else {
            return nil
        }
        let hexCode = columns[Keys.hexCode.rawValue]
        let dateUpdated = TimeInterval(columns[Keys.keyDateChanged.rawValue])
            .flatMap { Date(timeIntervalSince1970: $0) }
        let deadline  = TimeInterval(columns[Keys.keyDeadline.rawValue])
            .flatMap { Date(timeIntervalSince1970: $0) }
        let priority = Priority.init(rawValue: columns[Keys.keyPriority.rawValue]) ?? .basic// ??
        let updatedID = columns[Keys.keyUpdatedID.rawValue]
        return TodoItem(
            id: id,
            text: text,
            deadline: deadline,
            isDone: isDone,
            hexCode: hexCode,
            priority: priority,
            dateCreated: dateCreated,
            dateChanged: dateUpdated,
            updatedID: updatedID
        )
    }

    // MARK: - JSON

    var json: Any {

        var result: [String: Any] = [
            Keys.keyId.description: id,
            Keys.keyText.description: text,
            Keys.keyIsDone.description: isDone,
            Keys.keyDateCreated.description: Int(dateCreated.timeIntervalSince1970)
        ]
        if let hexCode {
            result[Keys.hexCode.description] = hexCode
        }
        if let deadline {
            result[Keys.keyDeadline.description] = Int(deadline.timeIntervalSince1970)
        }

        if priority != .basic {
            result[Keys.keyPriority.description] = priority.rawValue
        }

        if let dateChanged {
            result[Keys.keyDateChanged.description] = Int(dateChanged.timeIntervalSince1970)
        }
        return result
    }

    // MARK: - JSON parsing

    static func parse(json: Any) -> TodoItem? {

        guard let object = json as? [String: Any] else {
            return nil
        }
        guard
            let id = object[Keys.keyId.description] as? String,
            let text = object[Keys.keyText.description] as? String,
            let dateCreated = (object[Keys.keyDateCreated.description] as? TimeInterval)
                .flatMap({ Date(timeIntervalSince1970: $0) }),
            let isDone = object[Keys.keyIsDone.description] as? Bool

        else {
            return nil
        }
        let hexCode = object[Keys.hexCode.description] as? String
        let dateUpdated = (object[Keys.keyDateChanged.description] as? TimeInterval)
            .flatMap { Date(timeIntervalSince1970: $0) }
        let deadline  = (object[Keys.keyDeadline.description] as? TimeInterval)
            .flatMap { Date(timeIntervalSince1970: $0) }
        let priority = Priority.init(rawValue: object[Keys.keyPriority.description] as? String ?? "" ) ?? .basic
        let updatedID = object[Keys.keyUpdatedID.description] as? String ?? UIDevice.current.identifierForVendor!.uuidString

        return TodoItem(
            id: id,
            text: text,
            deadline: deadline,
            isDone: isDone,
            hexCode: hexCode,
            priority: priority,
            dateCreated: dateCreated,
            dateChanged: dateUpdated,
            updatedID: updatedID
        )
    }
}

