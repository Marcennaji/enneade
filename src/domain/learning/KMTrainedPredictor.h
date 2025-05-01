// Copyright (c) 2023-2025 Orange. All rights reserved.
// This software is distributed under the BSD 3-Clause-clear License, the text of which is available
// at https://spdx.org/licenses/BSD-3-Clause-Clear.html or see the "LICENSE" file for more details.

#pragma once

class KMClustering;
class KMParameters;
class KMCluster;

#include "KWTrainedPredictor.h"

/////////////////////////////////////////////////////////////////////////////
/// Predicteur issu de l'apprentissage kmean (cas non supervis�)
//

class KMTrainedPredictor : public KWTrainedPredictor
{
public:

	KMTrainedPredictor();
	~KMTrainedPredictor();

	int GetTargetType() const;

	/** reconstituer un resultat K-Means a partir du dico de modelisation */
	KMClustering* CreateModelingClustering();

	/** extraire les intervalles/modalites des attributs necessaires, a partir d'un dico */
	void ExtractPartitions(KWClass* aClass);

	/** acces au modele resultant d'un apprentissage KMean, reconstitu� a partir d'un dico de modelisation */
	KMClustering* GetModelingClustering() const;

	/** creer les clusters dans un resultat kmean, a partir d'un dico de modelisation
	*  NB. cette methode statique est egalement utilisee par le code de la classe KMTrainedClassifier */
	static bool CreateClusters(KWClass* predictorClass, KMClustering*);

	static void AddCellIndexAttributes(KWTrainedPredictor* trainedPredictor);

	/////////////////////////////////////////////////////////
	///// Implementation
protected:

	/** creer les clusters dans un resultat kmean, a partir d'un attribut "DistanceCluster" */
	static KMCluster* CreateCluster(KWAttribute* distanceClusterAttribute, KMParameters*, KWClass* predictorClass);

	/** creer des clusters a partir d'un modele, crees selon la norme L1 ou L2 */
	static KMCluster* CreateClusterL1L2Norm(KWAttribute* distanceClusterAttribute, KMParameters* parameters,
		KWClass* predictorClass);

	/** creer des clusters a partir d'un modele, crees selon la norme Cosine */
	static KMCluster* CreateClusterCosineNorm(KWAttribute* distanceClusterAttribute, KMParameters* parameters,
		KWClass* predictorClass);

	/** a partir d'un modele existant, l'extraire l'information necessaire a la reconstitution d'un clustering,
	sur un attribut de type RankNormalization */
	void ExtractRankNormalization(const KWAttribute* attribute);

	/** a partir d'un modele existant, l'extraire l'information necessaire a la reconstitution d'un clustering,
	sur un attribut de type BasicGrouping */
	void ExtractBasicGrouping(const KWAttribute* attribute);

	/** modele reconstitu� a partir d'un dico de modelisation, ou recuper� a partir d'un apprentissage effectu�) */
	KMClustering* kmModelingClustering;

	/** parametres d'un traitement kmean */
	KMParameters* parameters;

};

inline KMClustering* KMTrainedPredictor::GetModelingClustering() const {
	return kmModelingClustering;
}

