import org.gradle.api.tasks.Delete
import org.gradle.api.file.Directory

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Optional: Relocate build directory (only if you're intentionally customizing output paths)
val newBuildDir: Directory = layout.buildDirectory.dir("../../build").get()
layout.buildDirectory.set(newBuildDir)

subprojects {
    // Set subproject-specific build directories
    val subprojectBuildDir: Directory = newBuildDir.dir(name)
    layout.buildDirectory.set(subprojectBuildDir)
    
    evaluationDependsOn(":app")
}

// Register a global clean task
tasks.register<Delete>("clean") {
    delete(layout.buildDirectory)
}
