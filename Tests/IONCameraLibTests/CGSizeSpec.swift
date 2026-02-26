import Nimble
import Quick
@testable import OSCameraLib

class CGSizeSpec: QuickSpec {
    override func spec() {
        var size: CGSize!
        
        describe("Given a size set on the picture options") {
            context("when setting the CGSize") {
                it("then all properties should match") {
                    let optionsSize = IONCAMRSizeConfigurations.sizeSet
                    size = CGSize(size: optionsSize)
                    
                    expect(size.height).to(equal(CGFloat(optionsSize.height)))
                    expect(size.width).to(equal(CGFloat(optionsSize.width)))
                }
            }
        }
    }
}
