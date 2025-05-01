// Copyright (c) 2023-2025 Orange. All rights reserved.
// This software is distributed under the BSD 3-Clause-clear License, the text of which is available
// at https://spdx.org/licenses/BSD-3-Clause-Clear.html or see the "LICENSE" file for more details.

#pragma once

class KMClassifierEvaluation;
class KMCluster;

#include "KWPredictorEvaluationTask.h"

#include "Object.h"
#include "domain/clustering/KMClustering.h"



////////////////////////////////////////////////////////////////////////////////
/// Tache d'evaluation d'un classifieur KMean sur une base de donnees
class KMClassifierEvaluationTask : public KWClassifierEvaluationTask
{
public:
	// Constructeur
	KMClassifierEvaluationTask();
	~KMClassifierEvaluationTask();

	// Evaluation d'un predicteur sur une base.
	// Stockage de resultats sur l'objet mandataire KWPredictorEvaluation
	virtual boolean Evaluate(KWPredictor* predictor,
		KWDatabase* database,
		KWPredictorEvaluation* predictorEvaluation);

	longint GetReadInstancesForMedianComputation() const;

	KMClustering* GetClustering() const;

	longint GetInstanceEvaluationNumber() const;

	/** cle = nom d'attribut. Valeur = objet KWFrequencyTable, contenant le comptage des modalit�s group�es ou d'intervalles pour un attribut donn� */
	const ObjectDictionary& GetGroupedModalitiesFrequencyTables() const;

	/** cle = nom d'attribut. Valeur = objet KWFrequencyTable, contenant le comptage des modalit�s non group�es pour un attribut donn� */
	const ObjectDictionary& GetAtomicModalitiesFrequencyTables() const;


	///////////////////////////////////////////////////////////////////////////////
	////  Implementation
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

	void InitializeModalitiesProbs();

	void UpdateModalitiesProbs(const KWObject* kwoObject, const int idCluster);

	////////////////////////////////////  variables membres ///////////////////////////////

	KMClassifierEvaluation* kmClassifierEvaluation;

	longint lInstancesWithMissingValues;

	longint lInstanceEvaluationNumber;

	/**
	Cl� = nom de l'attribut, valeur = ObjectArray * contenant des StringObject * --> liste de toutes les modalit�s groupees ou intervalles d'un attribut */
	ObjectDictionary* odAttributesPartitions;

	/**
	Cl� = nom de l'attribut, valeur = ObjectArray * contenant des StringObject * --> liste de toutes les modalit�s non group�es ('atomiques') d'un attribut */
	ObjectDictionary* odAtomicModalities;

	KMClustering* kmEvaluationClustering;

	KMCluster* kmGlobalCluster;

	KWAttribute* targetAttribute;

	/** cle = nom d'attribut. Valeur = objet KWFrequencyTable, contenant le comptage des modalit�s group�es ou d'intervalles pour un attribut donn� */
	ObjectDictionary odGroupedModalitiesFrequencyTables;

	/** cle = nom d'attribut. Valeur = objet KWFrequencyTable, contenant le comptage des modalit�s non group�es pour un attribut donn� */
	ObjectDictionary odAtomicModalitiesFrequencyTables;

	longint lReadInstancesForMedianComputation;;

	ObjectArray* evaluationInstances;
};

inline 	longint KMClassifierEvaluationTask::GetReadInstancesForMedianComputation() const {
	return lReadInstancesForMedianComputation;
}

inline KMClustering* KMClassifierEvaluationTask::GetClustering() const {
	return kmEvaluationClustering;
}

inline longint KMClassifierEvaluationTask::GetInstanceEvaluationNumber() const {
	return lInstanceEvaluationNumber;
}

inline const ObjectDictionary& KMClassifierEvaluationTask::GetGroupedModalitiesFrequencyTables() const {
	return odGroupedModalitiesFrequencyTables;
}

inline const ObjectDictionary& KMClassifierEvaluationTask::GetAtomicModalitiesFrequencyTables() const {
	return odAtomicModalitiesFrequencyTables;
}

