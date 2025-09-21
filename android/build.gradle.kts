buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:7.0.2'
        classpath 'com.google.gms:google-services:4.4.2' // ✅ Correct Maven format (note the ":" instead of ".")
    }
}

plugins {
    id("com.google.gms.google-services") version "4.4.2" apply false // ✅ This is fine
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}
