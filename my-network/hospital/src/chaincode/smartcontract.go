package chaincode

import (
	"encoding/json"
	"fmt"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// SmartContract provides functions for managing an Asset
type SmartContract struct {
	contractapi.Contract
}

// Asset describes basic details of what makes up a simple asset
type Asset struct {
	PatientID      string `json:"patient_id"`
	Name           string `json:"name"`
	Age            int    `json:"age"`
	Gender         string `json:"gender"`
	DoctorID       string `json:"doctor_id"`
	Hospital       string `json:"hospital"`
}

// InitLedger adds a base set of assets to the ledger
func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
	assets := []Asset{
               {PatientID: "patient1", Name: "Kim", Age: 23, Gender: "F" , DoctorID: "doctor1" , Hospital: "KonkukUniv"},
	       {PatientID: "patient2", Name: "Lee", Age: 26, Gender: "F" , DoctorID: "doctor3" , Hospital: "KonkukUniv"},
               {PatientID: "patient3", Name: "Park", Age: 32, Gender: "M" , DoctorID: "doctor2" , Hospital: "SeoulUniv"},
               {PatientID: "patient4", Name: "Cha", Age: 46, Gender: "M" , DoctorID: "doctor1" , Hospital: "YounseiUniv"},
               {PatientID: "patient5", Name: "Kim", Age: 23, Gender: "M" , DoctorID: "doctor3" , Hospital: "KoreaUniv"},
	}

	for _, asset := range assets {
		assetJSON, err := json.Marshal(asset)
		if err != nil {
			return err
		}

		err = ctx.GetStub().PutState(asset.PatientID, assetJSON)
		if err != nil {
			return fmt.Errorf("failed to put to world state. %v", err)
		}
	}

	return nil
}

// CreateAsset issues a new asset to the world state with given details.
func (s *SmartContract) CreateAsset(ctx contractapi.TransactionContextInterface, patient_id string, name string, age int, gender string, doctor_id string, hospital string) error {
	exists, err := s.AssetExists(ctx, patient_id)
	if err != nil {
		return err
	}
	if exists {
		return fmt.Errorf("the patient %s already exists",patient_id)
	}

	asset := Asset{
		PatientID:       patient_id,
		Name:            name,
		Age:             age,
		Gender:          gender,
		DoctorID:        doctor_id,
                Hospital:        hospital,
	}
	assetJSON, err := json.Marshal(asset)
	if err != nil {
		return err
	}

	return ctx.GetStub().PutState(patient_id, assetJSON)
}

// ReadAsset returns the asset stored in the world state with given id.
func (s *SmartContract) ReadAsset(ctx contractapi.TransactionContextInterface, patient_id string) (*Asset, error) {
	assetJSON, err := ctx.GetStub().GetState(patient_id)
	if err != nil {
		return nil, fmt.Errorf("failed to read from world state: %v", err)
	}
	if assetJSON == nil {
		return nil, fmt.Errorf("the patient %s does not exist", patient_id)
	}

	var asset Asset
	err = json.Unmarshal(assetJSON, &asset)
	if err != nil {
		return nil, err
	}

	return &asset, nil
}

// UpdateAsset updates an existing asset in the world state with provided parameters.
func (s *SmartContract) UpdateAsset(ctx contractapi.TransactionContextInterface, patient_id string, name string, age int, gender string, doctor_id string, hospital string) error {
	exists, err := s.AssetExists(ctx, patient_id)
	if err != nil {
		return err
	}
	if !exists {
		return fmt.Errorf("the patient %s does not exist", patient_id)
	}

	// overwriting original asset with new asset
	asset := Asset{
	        PatientID:       patient_id,
                Name:            name,
                Age:             age,
                Gender:          gender,
                DoctorID:        doctor_id,
                Hospital:        hospital,
}
	assetJSON, err := json.Marshal(asset)
	if err != nil {
		return err
	}

	return ctx.GetStub().PutState(patient_id, assetJSON)
}

// DeleteAsset deletes an given asset from the world state.
func (s *SmartContract) DeleteAsset(ctx contractapi.TransactionContextInterface, patient_id string) error {
	exists, err := s.AssetExists(ctx, patient_id)
	if err != nil {
		return err
	}
	if !exists {
		return fmt.Errorf("the patient %s does not exist",patient_id)
	}

	return ctx.GetStub().DelState(patient_id)
}

// AssetExists returns true when asset with given ID exists in world state
func (s *SmartContract) AssetExists(ctx contractapi.TransactionContextInterface, patient_id string) (bool, error) {
	assetJSON, err := ctx.GetStub().GetState(patient_id)
	if err != nil {
		return false, fmt.Errorf("failed to read from world state: %v", err)
	}

	return assetJSON != nil, nil
}

// TransferAsset updates the owner field of asset with given id in world state.
func (s *SmartContract) TransferAsset(ctx contractapi.TransactionContextInterface, patient_id string, newName string) error {
	asset, err := s.ReadAsset(ctx, patient_id)
	if err != nil {
		return err
	}

	asset.Name = newName
	assetJSON, err := json.Marshal(asset)
	if err != nil {
		return err
	}

	return ctx.GetStub().PutState(patient_id, assetJSON)
}

// GetAllAssets returns all assets found in world state
func (s *SmartContract) GetAllAssets(ctx contractapi.TransactionContextInterface) ([]*Asset, error) {
	// range query with empty string for startKey and endKey does an
	// open-ended query of all assets in the chaincode namespace.
	resultsIterator, err := ctx.GetStub().GetStateByRange("", "")
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	var assets []*Asset
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}

		var asset Asset
		err = json.Unmarshal(queryResponse.Value, &asset)
		if err != nil {
			return nil, err
		}
		assets = append(assets, &asset)
	}

	return assets, nil
}
