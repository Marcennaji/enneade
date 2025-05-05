#include "fixtures/ClusteringTestSuite.h"

#include "domain/clustering/KMParameters.h"
#include "domain/clustering/KMClustering.h"

TEST_F(ClusteringTestSuite, DefaultInitialization) {
    KMParameters parameters;
    KMClustering clustering(&parameters);

    EXPECT_EQ(clustering.GetIterationsDone(), 0) << "Iterations done should be 0 on initialization.";
    EXPECT_EQ(clustering.GetDroppedClustersNumber(), 0) << "Dropped clusters number should be 0 on initialization.";
    EXPECT_EQ(clustering.GetInstancesWithMissingValues(), 0) << "Instances with missing values should be 0 on initialization.";
}
