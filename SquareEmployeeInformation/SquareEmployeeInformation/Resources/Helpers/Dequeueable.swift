//
//  Dequeueable.swift
//  SquareEmployeeInformation
//
//  Created by Jayden Garrick on 1/25/21.
//

import UIKit

protocol Dequeuable {
    var frame: CGRect { get set }
    
    func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> UICollectionViewCell
    func dequeueReusableSupplementaryView(ofKind elementKind: String, withReuseIdentifier identifier: String, for indexPath: IndexPath) -> UICollectionReusableView
    func cellForItem(at indexPath: IndexPath) -> UICollectionViewCell?
}

extension UICollectionView: Dequeuable {}

