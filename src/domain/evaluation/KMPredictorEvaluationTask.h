// Copyright (c) 2023-2025 Orange. All rights reserved.
// This software is distributed under the BSD 3-Clause-clear License, the text of which is available
// at https://spdx.org/licenses/BSD-3-Clause-Clear.html or see the "LICENSE" file for more details.

#pragma once

class KMPredictorEvaluation;
class KMCluster;

#include "KWPredictorEvaluationTask.h"

#include "Object.h"

#include "domain/clustering/KMClustering.h"

//////////////////////////////////////////////
/// tache d'evaluation d'un predicteur KMeans
//

class KMPredictorEvaluationTask : public KWPredictorEvaluationTask
{
public:
	// Constructeur
	KMPredictorEvaluationTask();
	~KMPredictorEvaluationTask();

	/** Evaluation d'un predicteur sur une base.
	   Stockage de resultats sur l'objet mandataire KWPredictorEvaluation */
	virtual boolean Evaluate(KWPredictor* predictor,
		KWDatabase* database,
		KWPredictorEvaluation* predictorEvaluation);

	/** acces au nombre d'instances utilisees lors du calcul des valeurs medianes */
	longint GetReadInstancesForMedianComputation() const;

	KMClustering* GetClustering() const;

	/** acces au nombre d'instances utilisees lors de l'evaluation */
	longint GetInstanceEvaluationNumber() const;

	/** cle = nom d'attribut. Valeur = objet KWFrequencyTable, contenant le comptage des modalit�s group�es ou d'intervalles pour un attribut donn� */
	const ObjectDictionary& GetGroupedModalitiesFrequencyTables() const;

	/** cle = nom d'attribut. Valeur = objet KWFrequencyTable, contenant le comptage des modalit�s non group�es pour un attribut donn� */
	const ObjectDictionary& GetAtomicModalitiesFrequencyTables() const;

	//////////////////////////////////////////////////////////////////////////////
	///// Implementation
protected:

	// Reimplementation des methodes virtuelles. NB. pour le moment, on ne traite pas en parallele
	const ALString GetTaskName() const override;
	PLParallelTask* Create() const override;
	boolean MasterInitialize() override;
	boolean MasterFinalize(boolean bProcessEndedCorrectly) override;

	/** evaluation lors de la premiere passe de lecture */
	KMCluster* UpdateEvaluationFirstDatabaseRead(KWPredictor* predictor, KWObject* kwoObject, const bool updateModalitiesProbs);

	/** evaluation lors de la seconde passe de lecture */
	KMCluster* UpdateEvaluationSecondDatabaseRead(KWObject* kwoObject);

	/** initialiser le dictionnaire contenant les probas de modalites : chaque poste pointe sur un objet KWFrequencyTable, correspondant aux intervalles d'un attribut */
	void InitializeModalitiesProbs();

	/** a partir d'une unsiatnce, mise a jour des frequences des modalites goupees et 'atomiques' (non groupees) */
	void UpdateModalitiesProbs(const KWObject* kwoObject, const int idCluster);

	////////////////////////////////////  variables membres ///////////////////////////////

	/** nombre d'instances ayant des valeurs manquantes parmi leurs attributs */
	longint lInstancesWithMissingValues;

	/** nbre d'instances utilisees lors de l'evaluation */
	longint lInstanceEvaluationNumber;

	/**
	Cl� = nom de l'attribut, valeur = ObjectArray * contenant des StringObject * --> liste de toutes les modalit�s groupees ou intervalles d'un attribut */
	ObjectDictionary* odAttributesPartitions;

	/**
	Cl� = nom de l'attribut, valeur = ObjectArray * contenant des StringObject * --> liste de toutes les modalit�s non group�es ('atomiques') d'un attribut */
	ObjectDictionary* odAtomicModalities;

	/** clustering de l'evaluation */
	KMClustering* kmEvaluationClustering;

	/** cluster global de l'evaluation */
	KMCluster* kmGlobalCluster;

	/** cle = nom d'attribut. Valeur = objet KWFrequencyTable, contenant le comptage des modalit�s group�es ou d'intervalles pour un attribut donn� */
	ObjectDictionary odGroupedModalitiesFrequencyTables;

	/** cle = nom d'attribut. Valeur = objet KWFrequencyTable, contenant le comptage des modalit�s non group�es pour un attribut donn� */
	ObjectDictionary odAtomicModalitiesFrequencyTables;

	/** nbre d'instances lues pour le calcul des valeurs medianes */
	longint iReadInstancesForMedianComputation;
};


inline 	longint KMPredictorEvaluationTask::GetReadInstancesForMedianComputation() const {
	return iReadInstancesForMedianComputation;
}

inline KMClustering* KMPredictorEvaluationTask::GetClustering() const {
	return kmEvaluationClustering;
}

inline longint KMPredictorEvaluationTask::GetInstanceEvaluationNumber() const {
	return lInstanceEvaluationNumber;
}

inline const ObjectDictionary& KMPredictorEvaluationTask::GetGroupedModalitiesFrequencyTables() const {
	return odGroupedModalitiesFrequencyTables;
}

inline const ObjectDictionary& KMPredictorEvaluationTask::GetAtomicModalitiesFrequencyTables() const {
	return odAtomicModalitiesFrequencyTables;
}

