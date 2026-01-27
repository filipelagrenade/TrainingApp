allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Fix for plugins that don't have namespace set (required for AGP 8+)
// Also forces compileSdk 34 for all subprojects (fixes isar_flutter_libs lStar issue)
subprojects {
    afterEvaluate {
        if (project.hasProperty("android")) {
            val android = project.extensions.findByName("android")
            if (android != null) {
                val androidExtension = android as com.android.build.gradle.BaseExtension
                if (androidExtension.namespace == null) {
                    androidExtension.namespace = project.group.toString()
                }
                // Force compileSdk 34 for all subprojects
                androidExtension.compileSdkVersion(34)
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
