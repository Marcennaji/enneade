#pragma once

#include <gtest/gtest.h>

#include "KWSTDatabaseTextFile.h"
#include "KWClassManagement.h"

class ClusteringTestSuite : public ::testing::Test {
    protected:
        // Shared dataset for the whole suite
        static ObjectArray instances;
    
        static void SetUpTestSuite() {
        }
    
        static void TearDownTestSuite() {
        }

        void SetUp() override {
        }

        void TearDown() override {
        }
    };


    