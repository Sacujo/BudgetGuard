import Foundation
import UIKit

public struct Entity {
    public let value: Decimal
    public let label: String
    
    public init(value: Decimal, label: String) {
        self.value = value
        self.label = label
    }
}

public class PieChartView: UIView {
    public var entities: [Entity] = [] {
        didSet { setNeedsDisplay() }
    }
    
    // Цвета для 6 сегментов
    private let segmentColors: [UIColor] = [
        UIColor(red: 0.22, green: 0.98, blue: 0.62, alpha: 1), // зеленый
        UIColor(red: 1.00, green: 0.89, blue: 0.00, alpha: 1), // желтый
        UIColor(red: 0.00, green: 0.60, blue: 1.00, alpha: 1), // синий
        UIColor(red: 1.00, green: 0.40, blue: 0.40, alpha: 1), // красный
        UIColor(red: 0.60, green: 0.40, blue: 1.00, alpha: 1), // фиолетовый
        UIColor(red: 0.60, green: 0.60, blue: 0.60, alpha: 1)  // серый ("Остальные")
    ]
    // --- Animation state ---
    private var oldEntities: [Entity] = []
    private var newEntities: [Entity] = []
    private var animationDisplayLink: CADisplayLink?
    private var animationStartTime: CFTimeInterval = 0
    private let animationDuration: CFTimeInterval = 0.8
    private var animationProgress: CGFloat = 0 // 0...1
    private var isAnimating = false
    
    public func setEntities(_ entities: [Entity], animated: Bool) {
        guard animated else {
            self.entities = entities
            return
        }
        guard !isAnimating else { return } // не запускать параллельно
        oldEntities = self.entities
        newEntities = entities
        animationProgress = 0
        isAnimating = true
        animationStartTime = CACurrentMediaTime()
        animationDisplayLink?.invalidate()
        animationDisplayLink = CADisplayLink(target: self, selector: #selector(handleAnimationTick))
        animationDisplayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func handleAnimationTick() {
        let elapsed = CACurrentMediaTime() - animationStartTime
        let progress = min(CGFloat(elapsed / animationDuration), 1)
        animationProgress = progress
        setNeedsDisplay()
        if progress >= 1 {
            animationDisplayLink?.invalidate()
            animationDisplayLink = nil
            isAnimating = false
            self.entities = newEntities
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }
    
    public override func draw(_ rect: CGRect) {
        if isAnimating {
            let totalAngle: CGFloat = 360
            let half = 0.5
            let context = UIGraphicsGetCurrentContext()!
            if oldEntities.isEmpty {
                // Анимированное появление с нуля: новый график появляется с 180° до 360°
                let angle = (totalAngle / 2) + animationProgress * (totalAngle / 2) // 180...360
                let radians = angle * .pi / 180
                context.saveGState()
                context.translateBy(x: rect.midX, y: rect.midY)
                context.rotate(by: radians)
                context.translateBy(x: -rect.midX, y: -rect.midY)
                let alpha = animationProgress
                drawPie(in: rect, entities: newEntities, alpha: alpha)
                drawLegend(in: rect, entities: newEntities, alpha: alpha)
                context.restoreGState()
            } else if animationProgress < half {
                // Первая половина: старый график вращается от 0 до 180° и исчезает
                let angle = animationProgress / half * (totalAngle / 2) // 0...180
                let radians = angle * .pi / 180
                context.saveGState()
                context.translateBy(x: rect.midX, y: rect.midY)
                context.rotate(by: radians)
                context.translateBy(x: -rect.midX, y: -rect.midY)
                let alpha = 1 - animationProgress / half
                drawPie(in: rect, entities: oldEntities, alpha: alpha)
                drawLegend(in: rect, entities: oldEntities, alpha: alpha)
                context.restoreGState()
            } else {
                // Вторая половина: новый график вращается от 180° до 360° и появляется
                let localProgress = (animationProgress - half) / half // 0...1
                let angle = (totalAngle / 2) + localProgress * (totalAngle / 2) // 180...360
                let radians = angle * .pi / 180
                context.saveGState()
                context.translateBy(x: rect.midX, y: rect.midY)
                context.rotate(by: radians)
                context.translateBy(x: -rect.midX, y: -rect.midY)
                let alpha = localProgress
                drawPie(in: rect, entities: newEntities, alpha: alpha)
                drawLegend(in: rect, entities: newEntities, alpha: alpha)
                context.restoreGState()
            }
            return
        }
        // Обычный режим
        drawPie(in: rect, entities: entities, alpha: 1)
        drawLegend(in: rect, entities: entities, alpha: 1)
    }
    
    private func drawPie(in rect: CGRect, entities: [Entity], alpha: CGFloat) {
        guard !entities.isEmpty else { return }
        // 1. Готовим данные: максимум 5 сегментов + "Остальные"
        let sorted = entities.sorted { ($0.value as NSDecimalNumber).doubleValue > ($1.value as NSDecimalNumber).doubleValue }
        let top5 = Array(sorted.prefix(5))
        let rest = sorted.dropFirst(5)
        let restValue = rest.reduce(Decimal(0)) { $0 + $1.value }
        var chartEntities = top5
        if restValue > 0 {
            chartEntities.append(Entity(value: restValue, label: "Остальные"))
        }
        let total = chartEntities.reduce(Decimal(0)) { $0 + $1.value }
        guard total > 0 else { return }
        let lineWidth: CGFloat = 18
        let radius = min(rect.width, rect.height) / 2 - lineWidth
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var startAngle = -CGFloat.pi / 2
        for (i, entity) in chartEntities.enumerated() {
            let value = (entity.value as NSDecimalNumber).doubleValue
            let percent = value / (total as NSDecimalNumber).doubleValue
            let endAngle = startAngle + CGFloat(percent) * 2 * .pi
            let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            path.lineWidth = lineWidth
            segmentColors[i % segmentColors.count].withAlphaComponent(alpha).setStroke()
            path.stroke()
            startAngle = endAngle
        }
    }
    private func drawLegend(in rect: CGRect, entities: [Entity], alpha: CGFloat) {
        guard !entities.isEmpty else { return }
        let sorted = entities.sorted { ($0.value as NSDecimalNumber).doubleValue > ($1.value as NSDecimalNumber).doubleValue }
        let top5 = Array(sorted.prefix(5))
        let rest = sorted.dropFirst(5)
        let restValue = rest.reduce(Decimal(0)) { $0 + $1.value }
        var chartEntities = top5
        if restValue > 0 {
            chartEntities.append(Entity(value: restValue, label: "Остальные"))
        }
        let total = chartEntities.reduce(Decimal(0)) { $0 + $1.value }
        guard total > 0 else { return }
        let legendFont = UIFont.systemFont(ofSize: 8)
        let dotSize: CGFloat = 4
        let spacing: CGFloat = 2
        let legendLines = chartEntities.enumerated().map { (i, entity) -> NSAttributedString in
            let percent = Int(round((entity.value as NSDecimalNumber).doubleValue / (total as NSDecimalNumber).doubleValue * 100))
            let text = "  \(percent)% \(entity.label)"
            let attr = NSMutableAttributedString(string: text, attributes: [
                .font: legendFont,
                .foregroundColor: UIColor.black.withAlphaComponent(alpha)
            ])
            // Цветная точка
            let dot = NSTextAttachment()
            let dotRect = CGRect(x: 0, y: (legendFont.capHeight-dotSize)/2, width: dotSize, height: dotSize)
            UIGraphicsBeginImageContextWithOptions(CGSize(width: dotSize, height: dotSize), false, 0)
            let dotCtx = UIGraphicsGetCurrentContext()!
            dotCtx.setFillColor(segmentColors[i % segmentColors.count].withAlphaComponent(alpha).cgColor)
            dotCtx.fillEllipse(in: CGRect(origin: .zero, size: CGSize(width: dotSize, height: dotSize)))
            let dotImg = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            dot.image = dotImg
            dot.bounds = dotRect
            attr.insert(NSAttributedString(attachment: dot), at: 0)
            return attr
        }
        let legendHeight = CGFloat(legendLines.count) * legendFont.lineHeight + CGFloat(legendLines.count-1) * spacing
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let legendOrigin = CGPoint(x: center.x, y: center.y - legendHeight/2)
        for (idx, line) in legendLines.enumerated() {
            let size = line.size()
            let lineOrigin = CGPoint(x: legendOrigin.x - size.width/2, y: legendOrigin.y + CGFloat(idx) * (legendFont.lineHeight + spacing))
            line.draw(at: lineOrigin)
        }
    }
}
