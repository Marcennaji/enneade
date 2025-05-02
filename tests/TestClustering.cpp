#include "IrisDatasetFixture.h"

TEST_F(IrisDatasetFixture, PerformSingleReplicate) {
    // Initialize the parameters
    KMParameters parameters;
    parameters.SetKValue(3); // Set the number of clusters (Iris dataset has 3 classes)
    parameters.SetDistanceType(KMParameters::L2Norm); // Use L2 norm (Euclidean distance)
    parameters.SetMaxIterations(100); // Set a maximum number of iterations

    // Perform clustering
    KMClustering clustering(&parameters);
    bool success = clustering.ComputeReplicate(&instances, nullptr); // Perform clustering without a target attribute

    // Validate the clustering result
    ASSERT_TRUE(success) << "Clustering failed";
    ASSERT_EQ(clustering.GetClusters()->GetSize(), 3) << "Expected 3 clusters";
}

TEST_F(IrisDatasetFixture, CheckInstanceCount) {
    // Verify the number of instances in the dataset
    ASSERT_EQ(instances.GetSize(), 150) << "Expected 150 instances in the Iris dataset";
}