#pragma once

#include <gtest/gtest.h>

#include "KWSTDatabaseTextFile.h"
#include "KWClassManagement.h"

class ClusteringTestSuite : public ::testing::Test {
    protected:
        // Shared dataset for the whole suite
        static ObjectArray instances;
    
        static void SetUpTestSuite() {

            ALString base = "C:/Users/Utilisateur/dev/perso/enneade/tests/data/datasets/Iris/";
           
            KWClassManagement classManagement;
            classManagement.SetClassFileName(base + "Iris.kdic");
            classManagement.ReadClasses();
            classManagement.SetClassName("Iris");
            
            KWSTDatabaseTextFile database;           
            database.SetDatabaseName(base +  + "/Iris.txt");
            database.SetClassName("Iris");
    
            ASSERT_TRUE(database.OpenForRead()) << "Failed to open Iris dataset";
    
            while (!database.IsEnd()) {
                KWObject* instance = database.Read();
                if (instance != nullptr) {
                    instances.Add(instance);
                }
            }
            database.Close();
    
            ASSERT_EQ(instances.GetSize(), 150) << "Iris dataset shoud contain 150 instances";
        }
    
        static void TearDownTestSuite() {
            instances.DeleteAll();
        }

        void SetUp() override {
        }

        void TearDown() override {
        }
    };


    