#pragma once

#include <gtest/gtest.h>
#include "domain/clustering/KMClustering.h"
#include "KWDatabase.h"

class IrisDatasetFixture : public ::testing::Test {
protected:
    ObjectArray instances; // Shared dataset for all tests

    void SetUp() override {
        KWDatabase database;
        database.SetDatabaseName("datasets/Iris.txt"); 
        database.SetClassName("Iris"); 
        ASSERT_TRUE(database.OpenForRead()) << "Failed to open Iris dataset";

        // Read all instances from the database
        while (!database.IsEnd()) {
            KWObject* instance = database.Read();
            if (instance != nullptr) {
                instances.Add(instance);
            }
        }
        database.Close();

        // Ensure the dataset is loaded
        ASSERT_GT(instances.GetSize(), 0) << "No instances loaded from Iris dataset";
    }

    void TearDown() override {
        // Clean up the dataset after each test
        instances.DeleteAll();
    }
};