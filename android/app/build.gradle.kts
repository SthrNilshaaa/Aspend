signingConfigs {
    create("release") {
        if (keystorePropertiesFile.exists()) {
            val storeFilePath = keystoreProperties.getProperty("storeFile")
            val storePassword = keystoreProperties.getProperty("storePassword")
            val keyAlias = keystoreProperties.getProperty("keyAlias")
            val keyPassword = keystoreProperties.getProperty("keyPassword")
            
            if (storeFilePath != null && storePassword != null && keyAlias != null && keyPassword != null) {
                storeFile = file(storeFilePath)
                this.storePassword = storePassword
                this.keyAlias = keyAlias
                this.keyPassword = keyPassword
                
                println("✓ Signing config loaded successfully")
                println("  storeFile: $storeFilePath")
                println("  keyAlias: $keyAlias")
            } else {
                println("⚠ Some signing properties are missing in key.properties")
            }
        } else {
            println("⚠ key.properties not found at: ${keystorePropertiesFile.absolutePath}")
        }
    }
}