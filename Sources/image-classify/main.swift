import Foundation
import ArgumentParser
import AppKit
import ImageClassify

public enum Errors: Error {
    case notFound
    case invalidImage
    case cgImage
    case processError
    case unsupportedOS
    case jsonEncoder
}

@available(macOS 10.15, *)
struct ImageClassifyCLI: ParsableCommand {

    @Argument(help:"The path to an image file to extract image classifications from  ")
    var inputFile: String
    
    func run() throws {
        
        let fm = FileManager.default
        
        if (!fm.fileExists(atPath: inputFile)){
            throw(Errors.notFound)
        }
        
        guard let im = NSImage(byReferencingFile:inputFile) else {
            throw(Errors.invalidImage)
        }
        
        guard let cgImage = im.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw(Errors.cgImage)
        }
        
        let ic = ImageClassify()
        let rsp = ic.ProcessImage(image: cgImage)
        
        switch rsp {
        case .failure(let error):
            throw(error)
        case .success(let data):

            let encoder = JSONEncoder()
            
            guard let encoded = try? encoder.encode(data) else {
                throw(Errors.jsonEncoder)
            }
            
            guard let json = String(data: encoded, encoding: .utf8) else {
                throw(Errors.jsonEncoder)
            }
            
            print(json)
        }
        
    }
}

if #available(macOS 10.15, *) {
    ImageClassifyCLI.main()
} else {
    throw(Errors.unsupportedOS)
}
