//
//  ContentView.swift
//  Rearview Millennium
//
//  Created by Felix Zheng on 9/15/26.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @State private var showSplash = true
    @State private var ascii = ""
    @State private var caption = ""
    @State private var leftText = ""
    @State private var rightText = ""

    @State private var initialized = false

    var body: some View {
        Group {
            if showSplash {
                splashView
            } else {
                sceneView
            }
        }
        .background(Color.black)
        .ignoresSafeArea()
        .onAppear {
            if !initialized {
                if initializeApp() {
                    showScene(choice: 0)
                }

                initialized = true

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                    showSplash = false
                }
            }
        }
    }

    private var splashView: some View {
        VStack(spacing: 4) {
            Text("Rearview Millennium")
                .font(.system(size: 24))
                .foregroundColor(.green)

            Text("Paralevels LLC")
                .font(.system(size: 18))
                .foregroundColor(.green)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
    
    private var sceneView: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {

                // ASCII image
                Text(ascii)
                    .font(.system(size: 7, design: .monospaced))
                    .foregroundColor(.green)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(0)
                    .frame(
                        width: geometry.size.width - 48,
                        alignment: .center
                    )
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 8)

                // Caption
                Text(caption)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .topLeading
                    )
                    .padding(.top, 4)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)

                // Bottom button row
                HStack(
                    alignment: .bottom,
                    spacing: 0
                ) {

                    // LEFT
                    Button(action: {
                        showScene(choice: 0)
                    }) {
                        Text(leftText)
                            .bold()
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .frame(
                                maxWidth: .infinity,
                                minHeight: 80,
                                maxHeight: 120
                            )
                            .background(Color.green)
                    }
                    .disabled(leftText.isEmpty)
                    .opacity(leftText.isEmpty ? 0 : 1)

                    // EXIT
                    Button(action: {
                        exitApp()
                    }) {
                        Text("EXIT")
                            .bold()
                            .font(.system(size: 10))
                            .foregroundColor(.blue)
                            .frame(
                                width: 70,
                                height: 50
                            )
                            .background(Color.black)
                    }

                    // RIGHT
                    Button(action: {
                        showScene(choice: 1)
                    }) {
                        Text(rightText)
                            .bold()
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .frame(
                                maxWidth: .infinity,
                                minHeight: 80,
                                maxHeight: 120
                            )
                            .background(Color.green)
                    }
                    .disabled(rightText.isEmpty)
                    .opacity(rightText.isEmpty ? 0 : 1)
                }
                .frame(
                    width: geometry.size.width - 48
                )
                .padding(.bottom, 16)
            }
            .padding(24)
            .frame(
                width: geometry.size.width,
                height: geometry.size.height,
                alignment: .top
            )
            .background(Color.black)
            .ignoresSafeArea()
        }
    }
    
    // MARK: - File Paths

    private func documentsDirectory() -> URL {
        FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
    }

    private func scenesDirectory() -> URL {
        documentsDirectory()
            .appendingPathComponent("scenes")
    }

    private func currFile() -> URL {
        documentsDirectory()
            .appendingPathComponent("curr")
    }

    // MARK: - Initialization

    private func initializeApp() -> Bool {
        let fileManager = FileManager.default

        do {
            let scenesDirectory = scenesDirectory()

            try fileManager.createDirectory(
                at: scenesDirectory,
                withIntermediateDirectories: true
            )

            // Find all bundled .scene files.
            var sceneFiles: [URL] = []

            if let files = Bundle.main.urls(
                forResourcesWithExtension: "scene",
                subdirectory: nil
            ) {
                sceneFiles.append(contentsOf: files)
            }

            if let files = Bundle.main.urls(
                forResourcesWithExtension: "scene",
                subdirectory: "scenes"
            ) {
                sceneFiles.append(contentsOf: files)
            }

            // Remove duplicates.
            sceneFiles = Array(
                Set(sceneFiles.map { $0.standardizedFileURL })
            )

            guard !sceneFiles.isEmpty else {
                ascii = "ERROR\n\nNO SCENE FILES FOUND IN APP BUNDLE."
                caption = "Check Target Membership and Copy Bundle Resources."
                return false
            }

            for sourceURL in sceneFiles {
                let destinationURL =
                    scenesDirectory.appendingPathComponent(
                        sourceURL.lastPathComponent
                    )

                if !fileManager.fileExists(
                    atPath: destinationURL.path
                ) {
                    try fileManager.copyItem(
                        at: sourceURL,
                        to: destinationURL
                    )
                }
            }

            // Create curr with -1 on first launch.
            if !fileManager.fileExists(
                atPath: currFile().path
            ) {
                try "-1\n".write(
                    to: currFile(),
                    atomically: true,
                    encoding: .utf8
                )
            }
            
            return true

        } catch {
            ascii = "ERROR\n\nUnable to install scene files."
            caption = error.localizedDescription
            return false
        }
    }

    // MARK: - Scene

    private func showScene(choice: Int32) {
        let basePath = documentsDirectory().path

        basePath.withCString { basePointer in

            guard let buffer =
                    genscene_ios(
                        basePointer,
                        choice
                    )
            else {
                ascii = "ERROR\n\nUnable to generate scene."
                return
            }

            let output = String(
                cString: buffer
            )

            free(buffer)

            let lines = output.components(
                separatedBy: "\n"
            )

            // Lines 1–64
            if lines.count >= 64 {
                ascii = lines[0..<64]
                    .joined(separator: "\n")
            } else {
                ascii = output
            }

            // Line 66
            caption =
                lines.count > 65
                ? lines[65]
                : ""

            // Line 68
            leftText =
                lines.count > 67
                ? lines[67]
                : ""

            // Line 70
            rightText =
                lines.count > 69
                ? lines[69]
                : ""
        }
    }

    // MARK: - Exit

    private func exitApp() {
        let basePath = documentsDirectory().path

        basePath.withCString { basePointer in
            exit_reset_curr_ios(basePointer)
        }

        exit(0)
    }
}
