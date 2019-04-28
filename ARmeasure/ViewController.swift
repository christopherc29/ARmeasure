//
//  ViewController.swift
//  ARmeasure
//
//  Created by Christopher on 7/4/2019.
//  Copyright © 2019 Christopher. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    // MARK: - Interface Builder Connections
    @IBOutlet var sceneView: ARSCNView!
    
    // Spheres nodes
    var spheres: [SCNNode] = []
    
    // Measurement label
    var measurementLabel = UILabel()
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        measurementLabel.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 70)
        measurementLabel.backgroundColor = .white
        measurementLabel.text = "0 cm"
        measurementLabel.textAlignment = .center
        view.addSubview(measurementLabel)

        sceneView.delegate = self

        sceneView.showsStatistics = true
        
        // Creates a tap handler and then sets it to a constant
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        
        // Sets the amount of taps needed to trigger the handler
        tapRecognizer.numberOfTapsRequired = 1
        
        // Adds the handler to the scene view
        sceneView.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        
        // Gets the location of the tap and assigns it to a constant
        let location = sender.location(in: sceneView)
        
        // Searches for real world objects such as surfaces and filters out flat surfaces
        let hitTest = sceneView.hitTest(location, types: [ARHitTestResult.ResultType.featurePoint])
        
        // Assigns the most accurate result to a constant if it is non-nil
        guard let result = hitTest.last else { return }
        
        // Converts the matrix_float4x4 to an SCNMatrix4 to be used with SceneKit
        let transform = SCNMatrix4.init(result.worldTransform)
        
        // Creates an SCNVector3 with certain indexes in the matrix
        let vector = SCNVector3Make(transform.m41, transform.m42, transform.m43)
        
        // Makes a new sphere with the created method
        let sphere = newSphere(at: vector)
        
        // Checks if there is at least one sphere in the array
        if let first = spheres.first {
            
            // Adds a second sphere to the array
            spheres.append(sphere)
            measurementLabel.text = "\(sphere.distance(to: first)) cm"
            
            // If more that two are present...
            if spheres.count > 2 {
                
                // Iterate through spheres array
                for sphere in spheres {
                    
                    // Remove all spheres
                    sphere.removeFromParentNode()
                }
                
                // Remove extraneous spheres
                spheres = [spheres[2]]
            }
        } else {
            // Add the sphere
            spheres.append(sphere)
        }
        
        // Iterate through spheres array
        for sphere in spheres {
            
            // Add all spheres in the array
            self.sceneView.scene.rootNode.addChildNode(sphere)
        }
    }
    
    // Creates measuring endpoints
    func newSphere(at position: SCNVector3) -> SCNNode {
        
        let sphere = SCNSphere(radius: 0.01)
        
        // Converts the sphere into an SCNNode
        let node = SCNNode(geometry: sphere)
        
        // Positions the node based on the passed in position
        node.position = position
        
        // Creates a material that is recognized by SceneKit
        let material = SCNMaterial()
        
        // Converts the contents of the PNG file into the material
        material.diffuse.contents = UIColor.orange
        
        // Creates realistic shadows around the sphere
        material.lightingModel = .blinn
        
        // Wraps the newly made material around the sphere
        sphere.firstMaterial = material
        
        // Returns the node to the function
        return node
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
}

extension SCNNode {
    // Gets distance between two SCNNodes
    func distance(to destination: SCNNode) -> CGFloat {
        
        // Meters to inches conversion
        let cm: Float = 100
        
        // Difference between x-positions
        let dx = destination.position.x - position.x
        
        // Difference between x-positions
        let dy = destination.position.y - position.y
        
        // Difference between x-positions
        let dz = destination.position.z - position.z

        let meters = sqrt(dx*dx + dy*dy + dz*dz)

        return CGFloat(meters * cm)
    }
}
