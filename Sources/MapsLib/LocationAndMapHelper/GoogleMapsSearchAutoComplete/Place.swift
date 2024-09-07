//
//  Place.swift
//  
//
//  Created by Corptia 02 on 22/08/2023.
//

import Foundation

open class Place: NSObject {
  public let id: String
  public let mainAddress: String
  public let secondaryAddress: String
  override open var description: String {
    get { return "\(mainAddress), \(secondaryAddress)" }
  }
  public init(id: String, mainAddress: String, secondaryAddress: String) {
    self.id = id
    self.mainAddress = mainAddress
    self.secondaryAddress = secondaryAddress
  }
  convenience public init(prediction: [String: Any]) {
    let structuredFormatting = prediction["structured_formatting"] as? [String: Any]
    self.init(
      id: prediction["place_id"] as? String ?? "",
      mainAddress: structuredFormatting?["main_text"] as? String ?? "",
      secondaryAddress: structuredFormatting?["secondary_text"] as? String ?? ""
    )
  }
}
