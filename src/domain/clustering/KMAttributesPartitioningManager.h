// Copyright (c) 2023-2025 Orange. All rights reserved.
// This software is distributed under the BSD 3-Clause-clear License, the text of which is available
// at https://spdx.org/licenses/BSD-3-Clause-Clear.html or see the "LICENSE" file for more details.

#pragma once

#include "Object.h"

class KWDRValueGroups;
class KWDRIntervalBounds;


///  classe gerant les intervalles et modalites (groupees ou non) des attributs

class KMAttributesPartitioningManager : public Object
{
public:

	KMAttributesPartitioningManager();
	~KMAttributesPartitioningManager(void);

	KMAttributesPartitioningManager* Clone();

	void CopyFrom(const KMAttributesPartitioningManager* aSource);

	/** ajout des groupes de valeurs d'un attribut, a partir d'une regle de derivation */
	void AddValueGroups(KWDRValueGroups* kwdrGroups, const ALString attributeName, const int maxValuesToAdd, const bool supervisedMode);

	/** ajout des intervalles de valeurs d'un attribut, a partir d'une regle de derivation */
	void AddIntervalBounds(KWDRIntervalBounds* kwdrIntervalBounds, const ALString attributeName);

	/** cle = nom d'attribut, Valeur =  ObjectArray de modalit�s ou d'intervalles*/
	const ObjectDictionary& GetPartitions() const;

	/** cle = nom d'attribut. Valeur = ObjectArray de modalit�s non group�es */
	const ObjectDictionary& GetAtomicModalities() const;


protected:

	/** memorise un tableau des modalites group�es/intervalles, pour un attribut donn� */
	void AddAttributePartitions(const ALString attributeName, ObjectArray* partitions);

	/** memorise un tableau des modalites non group�es, pour un attribut donn� */
	void AddAtomicModalities(const ALString attributeName, ObjectArray* modalities);

	// ==============================================  attributs de la classe ===============================================

	/**
	Cl� = nom de l'attribut, valeur = ObjectArray * contenant des StringObject * --> liste de toutes les modalit�s groupees ou intervalles d'un attribut*/
	ObjectDictionary odAttributesPartitions;

	/**
	Cl� = nom de l'attribut, valeur = ObjectArray * contenant des StringObject * --> liste de toutes les modalit�s non group�es ('atomiques') d'un attribut */
	ObjectDictionary odAtomicModalities;

};




