#include <stdio.h>
#include <string>
#include "libccas.h"
#include "../../libcas/interface/libcasshared.h"
#include "libccas_Export.h"

using namespace std;
using namespace libcas;

#ifdef  __cplusplus
extern "C"
{
#endif

libccas_EXPORT CConstants newCConstants(uint8 quant, const char* config_filename, uint32 max_intruders)
{
	Constants* pConstants = new Constants();
	pConstants->quant = quant;
	pConstants->config_filename = config_filename;
	pConstants->max_intruders = max_intruders;

	return reinterpret_cast<CConstants>(pConstants);
}

libccas_EXPORT void delCConstants(CConstants cConstants)
{
	Constants* pConstants = reinterpret_cast<Constants*>(cConstants);

	delete pConstants;
	pConstants = NULL;
}

libccas_EXPORT CCASShared newCCASShared(CConstants cConstants, const char* library_path)
{
	Constants* pConstants = reinterpret_cast<Constants*>(cConstants);

	return reinterpret_cast<CCASShared>(new CASShared(*pConstants, string(library_path)));
}

libccas_EXPORT void delCCASShared(CCASShared cCASShared)
{
	CASShared* pCASShared = reinterpret_cast<CASShared*>(cCASShared);

	delete pCASShared;
	pCASShared = NULL;
}

libccas_EXPORT void reset(CCASShared cCASShared)
{
	CASShared* pCASShared = reinterpret_cast<CASShared*>(cCASShared);

	pCASShared->reset();
}

libccas_EXPORT COwnInput newCOwnInput(real dz, real z, real psi, real h, uint32 modes)
{
	OwnInput* pOwnInput = new OwnInput();
	pOwnInput->dz = dz;
	pOwnInput->z = z;
	pOwnInput->psi = psi;
	pOwnInput->h = h;
	pOwnInput->modes = modes;

	return reinterpret_cast<COwnInput>(pOwnInput);
}

libccas_EXPORT void delCOwnInput(COwnInput cOwnInput)
{
	OwnInput* pOwnInput = reinterpret_cast<OwnInput*>(cOwnInput);

	delete pOwnInput;
	pOwnInput = NULL;
}

libccas_EXPORT COwnInput getRefCOwnInput(CInput cInput)
{
	Input* pInput = reinterpret_cast<Input*>(cInput);

	return reinterpret_cast<COwnInput*>(&pInput->own);
}

libccas_EXPORT void setCOwnInput(COwnInput cOwnInput, real dz, real z, real psi, real h, uint32 modes)
{
	OwnInput* pOwnInput = reinterpret_cast<OwnInput*>(cOwnInput);
	pOwnInput->dz = dz;
	pOwnInput->z = z;
	pOwnInput->psi = psi;
	pOwnInput->h = h;
	pOwnInput->modes = modes;
}

libccas_EXPORT CIntruderInput newCIntruderInput(bool valid, uint32 id, uint32 modes, real sr, real chi,
	real z, uint8 cvc, uint8 vrc, uint8 vsb, int equipage,
	uint8 quant, uint8 sensitivity_index, uint8 protection_mode)
{
	IntruderInput* pIntruderInput = new IntruderInput();
	pIntruderInput->valid = valid;
	pIntruderInput->id = id;
	pIntruderInput->modes = modes;
	pIntruderInput->sr = sr;
	pIntruderInput->chi = chi;
	pIntruderInput->z = z;
	pIntruderInput->cvc = cvc;
	pIntruderInput->vrc = vrc;
	pIntruderInput->vsb = vsb;
	pIntruderInput->equipage = Equipage(equipage);
	pIntruderInput->quant = quant;
	pIntruderInput->sensitivity_index = sensitivity_index;
	pIntruderInput->protection_mode = protection_mode;

	return reinterpret_cast<CIntruderInput>(pIntruderInput);
}

libccas_EXPORT void delCIntruderInput(CIntruderInput cIntruderInput)
{
	IntruderInput* pIntruderInput = reinterpret_cast<IntruderInput*>(cIntruderInput);

	delete pIntruderInput;
	pIntruderInput = NULL;
}

libccas_EXPORT CIntruderInput getRefCIntruderInput(CCollectionIntruderInput cCollection, uint32 index)
{
	Collection<IntruderInput>* pCollection = reinterpret_cast<Collection<IntruderInput>*>(cCollection);

	return reinterpret_cast<IntruderInput*>(&((*pCollection)[index]));
}

libccas_EXPORT void setCIntruderInput(CIntruderInput cIntruderInput, bool valid, uint32 id, 
	uint32 modes, real sr, real chi, real z, uint8 cvc, uint8 vrc, uint8 vsb, int equipage,
	uint8 quant, uint8 sensitivity_index, uint8 protection_mode)
{
	IntruderInput* pIntruderInput = reinterpret_cast<IntruderInput*>(cIntruderInput);
	pIntruderInput->valid = valid;
	pIntruderInput->id = id;
	pIntruderInput->modes = modes;
	pIntruderInput->sr = sr;
	pIntruderInput->chi = chi;
	pIntruderInput->z = z;
	pIntruderInput->cvc = cvc;
	pIntruderInput->vrc = vrc;
	pIntruderInput->vsb = vsb;
	pIntruderInput->equipage = Equipage(equipage);
	pIntruderInput->quant = quant;
	pIntruderInput->sensitivity_index = sensitivity_index;
	pIntruderInput->protection_mode = protection_mode;
}

libccas_EXPORT CCollectionIntruderInput newCCollectionIntruderInput()
{
	return reinterpret_cast<CCollectionIntruderInput>(new Collection<IntruderInput>());
}

libccas_EXPORT void delCCollectionIntruderInput(CCollectionIntruderInput cCollection)
{
	Collection<IntruderInput>* pCollection = reinterpret_cast<Collection<IntruderInput>*>(cCollection);

	delete pCollection;
	pCollection = NULL;
}

libccas_EXPORT CCollectionIntruderInput getRefCCollectionIntruderInput(CInput cInput)
{
	Input* pInput = reinterpret_cast<Input*>(cInput);

	return reinterpret_cast<CCollectionIntruderInput*>(&(pInput->intruder));
}

libccas_EXPORT void resizeCCollectionIntrInput(CCollectionIntruderInput cCollection, uint32 size)
{
	Collection<IntruderInput>* pCollection = reinterpret_cast<Collection<IntruderInput>*>(cCollection);

	pCollection->resize(size);
}

libccas_EXPORT CIntruderInput getIndexCCollectionIntrInput(CCollectionIntruderInput cCollection, uint32 index)
{
	Collection<IntruderInput>* pCollection = reinterpret_cast<Collection<IntruderInput>*>(cCollection);

	return reinterpret_cast<CIntruderInput>(&((*pCollection)[index]));
}

libccas_EXPORT void setIndexCCollectionIntrInput(CCollectionIntruderInput cCollection, uint32 index, CIntruderInput cIntruderInput)
{
	Collection<IntruderInput>* pCollection = reinterpret_cast<Collection<IntruderInput>*>(cCollection);
	IntruderInput* pIntruderInput = reinterpret_cast<IntruderInput*>(cIntruderInput);

	(*pCollection)[index] = *pIntruderInput;
}

libccas_EXPORT uint32 sizeCCollectionIntrInput(CCollectionIntruderInput cCollection)
{
	Collection<IntruderInput>* pCollection = reinterpret_cast<Collection<IntruderInput>*>(cCollection);

	return (uint32)pCollection->size(); //casted from size_t, possible loss of data
}

libccas_EXPORT CInput newCInput()
{
	return reinterpret_cast<CInput>(new Input());
}

libccas_EXPORT void delCInput(CInput cInput)
{
	Input* pInput = reinterpret_cast<Input*>(cInput);
	delete pInput;
	pInput = NULL;
}

libccas_EXPORT CIntruderOutput newCIntruderOutput(uint32 id, uint8 cvc, uint8 vrc, uint8 vsb, real tds, uint8 code)
{
	IntruderOutput* pIntruderOutput = new IntruderOutput();
	pIntruderOutput->id = id;
	pIntruderOutput->cvc = cvc;
	pIntruderOutput->vrc = vrc;
	pIntruderOutput->vsb = vsb;
	pIntruderOutput->tds = tds;
	pIntruderOutput->code = code;

	return reinterpret_cast<CIntruderOutput>(pIntruderOutput);
}

libccas_EXPORT void delCIntruderOutput(CIntruderOutput cIntruderOutput)
{
	IntruderOutput* pIntruderOutput = reinterpret_cast<IntruderOutput*>(cIntruderOutput);

	delete pIntruderOutput;
	pIntruderOutput = NULL;
}

libccas_EXPORT CIntruderOutput getRefCIntruderOutput(CCollectionIntruderOutput cCollection, uint32 index)
{
	Collection<IntruderOutput>* pCollection = reinterpret_cast<Collection<IntruderOutput>*>(cCollection);

	return reinterpret_cast<IntruderInput*>(&((*pCollection)[index]));
}

libccas_EXPORT void setCIntrOutput_id(CIntruderOutput cIntruderOutput, uint32 id)
{
	IntruderOutput* pIntruderOutput = reinterpret_cast<IntruderOutput*>(cIntruderOutput);	
	pIntruderOutput->id = id;
}

libccas_EXPORT uint32 getCIntrOutput_id(CIntruderOutput cIntruderOutput)
{
	IntruderOutput* pIntruderOutput = reinterpret_cast<IntruderOutput*>(cIntruderOutput);

	return pIntruderOutput->id;
}

libccas_EXPORT uint8 getCIntrOutput_cvc(CIntruderOutput cIntruderOutput)
{
	IntruderOutput* pIntruderOutput = reinterpret_cast<IntruderOutput*>(cIntruderOutput);

	return pIntruderOutput->cvc;
}

libccas_EXPORT uint8 getCIntrOutput_vrc(CIntruderOutput cIntruderOutput)
{
	IntruderOutput* pIntruderOutput = reinterpret_cast<IntruderOutput*>(cIntruderOutput);

	return pIntruderOutput->vrc;
}

libccas_EXPORT uint8 getCIntrOutput_vsb(CIntruderOutput cIntruderOutput)
{
	IntruderOutput* pIntruderOutput = reinterpret_cast<IntruderOutput*>(cIntruderOutput);

	return pIntruderOutput->vsb;
}

libccas_EXPORT real getCIntrOutput_tds(CIntruderOutput cIntruderOutput)
{
	IntruderOutput* pIntruderOutput = reinterpret_cast<IntruderOutput*>(cIntruderOutput);

	return pIntruderOutput->tds;
}

libccas_EXPORT uint8 getCIntrOutput_code(CIntruderOutput cIntruderOutput)
{
	IntruderOutput* pIntruderOutput = reinterpret_cast<IntruderOutput*>(cIntruderOutput);

	return pIntruderOutput->code;
}

libccas_EXPORT CCollectionIntruderOutput newCCollectionIntruderOutput()
{
	return reinterpret_cast<CCollectionIntruderOutput>(new Collection<IntruderOutput>());
}

libccas_EXPORT void delCCollectionIntruderOutput(CCollectionIntruderOutput cCollection)
{
	Collection<IntruderOutput>* pCollection = reinterpret_cast<Collection<IntruderOutput>*>(cCollection);

	delete pCollection;
	pCollection = NULL;
}

libccas_EXPORT CCollectionIntruderOutput getRefCCollectionIntruderOutput(COutput cOutput)
{
	Output* pOutput = reinterpret_cast<Output*>(cOutput);

	return reinterpret_cast<CCollectionIntruderInput*>(&(pOutput->intruder));
}

libccas_EXPORT void resizeCCollectionIntrOutput(CCollectionIntruderOutput cCollection, uint32 size)
{
	Collection<IntruderOutput>* pCollection = reinterpret_cast<Collection<IntruderOutput>*>(cCollection);

	pCollection->resize(size);
}

libccas_EXPORT CIntruderOutput getIndexCCollectionIntrOutput(CCollectionIntruderOutput cCollection, uint32 index)
{
	Collection<IntruderOutput>* pCollection = reinterpret_cast<Collection<IntruderOutput>*>(cCollection);

	return reinterpret_cast<CIntruderOutput>(&((*pCollection)[index]));
}

libccas_EXPORT void setIndexCCollectionIntrOutput(CCollectionIntruderOutput cCollection, uint32 index, CIntruderOutput cIntruderOutput)
{
	Collection<IntruderOutput>* pCollection = reinterpret_cast<Collection<IntruderOutput>*>(cCollection);
	IntruderOutput* pIntruderOutput = reinterpret_cast<IntruderOutput*>(cIntruderOutput);

	(*pCollection)[index] = *pIntruderOutput;
}

libccas_EXPORT uint32 sizeCCollectionIntrOutput(CCollectionIntruderOutput cCollection)
{
	Collection<IntruderOutput>* pCollection = reinterpret_cast<Collection<IntruderOutput>*>(cCollection);

	return (uint32)pCollection->size(); //casted from size_t, possible loss of data
}

libccas_EXPORT COutput newCOutput()
{
	return reinterpret_cast<COutput>(new Output());
}

libccas_EXPORT void delCOutput(COutput cOutput)
{
	Output* pOutput = reinterpret_cast<Output*>(cOutput);

	delete pOutput;
	pOutput = NULL;
}

libccas_EXPORT uint8 getCOutput_cc(COutput cOutput)
{
	Output* pOutput = reinterpret_cast<Output*>(cOutput);

	return pOutput->cc;
}

libccas_EXPORT uint8 getCOutput_vc(COutput cOutput)
{
	Output* pOutput = reinterpret_cast<Output*>(cOutput);

	return pOutput->vc;
}

libccas_EXPORT uint8 getCOutput_ua(COutput cOutput)
{
	Output* pOutput = reinterpret_cast<Output*>(cOutput);

	return pOutput->ua;
}

libccas_EXPORT uint8 getCOutput_da(COutput cOutput)
{
	Output* pOutput = reinterpret_cast<Output*>(cOutput);

	return pOutput->da;
}

libccas_EXPORT real getCOutput_target_rate(COutput cOutput)
{
	Output* pOutput = reinterpret_cast<Output*>(cOutput);

	return pOutput->target_rate;
}

libccas_EXPORT bool getCOutput_turn_off_aurals(COutput cOutput)
{
	Output* pOutput = reinterpret_cast<Output*>(cOutput);

	return pOutput->turn_off_aurals;
}

libccas_EXPORT bool getCOutput_crossing(COutput cOutput)
{
	Output* pOutput = reinterpret_cast<Output*>(cOutput);

	return pOutput->crossing;
}

libccas_EXPORT bool getCOutput_alarm(COutput cOutput)
{
	Output* pOutput = reinterpret_cast<Output*>(cOutput);

	return pOutput->alarm;
}

libccas_EXPORT bool getCOutput_alert(COutput cOutput)
{
	Output* pOutput = reinterpret_cast<Output*>(cOutput);

	return pOutput->alert;
}

libccas_EXPORT real getCOutput_dh_min(COutput cOutput)
{
	Output* pOutput = reinterpret_cast<Output*>(cOutput);

	return pOutput->dh_min;
}

libccas_EXPORT real getCOutput_dh_max(COutput cOutput)
{
	Output* pOutput = reinterpret_cast<Output*>(cOutput);

	return pOutput->dh_max;
}

libccas_EXPORT uint8 getCOutput_sensitivity_index(COutput cOutput)
{
	Output* pOutput = reinterpret_cast<Output*>(cOutput);

	return pOutput->sensitivity_index;
}

libccas_EXPORT real getCOutput_ddh(COutput cOutput)
{
	Output* pOutput = reinterpret_cast<Output*>(cOutput);

	return pOutput->ddh;
}

#define CCASDEBUG
libccas_EXPORT void update(CCASShared cCASShared, CInput cInput, COutput cOutput)
{
	CASShared* pCASShared = reinterpret_cast<CASShared*>(cCASShared);
	Input* pInput = reinterpret_cast<Input*>(cInput);
	Output* pOutput = reinterpret_cast<Output*>(cOutput);

#ifdef CCASDEBUG
	print_CInput(cInput);
#endif

	try
	{
		pCASShared->update(*pInput, *pOutput);
	}
	catch (const char* e)
	{
		cout << "Exception in update: " << e << endl;
	}
	catch (...)
	{
		cout << "Exception in update: general" << endl;
	}

#ifdef CCASDEBUG
	print_COutput(cOutput);
#endif
}

libccas_EXPORT void print_CInput(CInput cInput)
{
	Input* pInput = reinterpret_cast<Input*>(cInput);
	cout << "Input" << endl;

	//Print Ownship
	cout << "Ownship:" << endl;
	cout << "dz = " << pInput->own.dz << endl;
	cout << "z = " << pInput->own.z << endl;
	cout << "psi = " << pInput->own.psi << endl;
	cout << "h = " << pInput->own.h << endl;
	cout << "modes = " << pInput->own.modes << endl;

	//Print intruders
	for (int i = 0; i < pInput->intruder.size(); i++)
	{
		cout << "Intruder " << i << ":" << endl;
		cout << "valid = " << pInput->intruder[i].valid << endl;
		cout << "id = " << (int)pInput->intruder[i].id << endl;
		cout << "modes = " << (int)pInput->intruder[i].modes << endl;
		cout << "sr = " << pInput->intruder[i].sr << endl;
		cout << "chi = " << pInput->intruder[i].chi << endl;
		cout << "z = " << pInput->intruder[i].z << endl;
		cout << "cvc = " << (int)pInput->intruder[i].cvc << endl;
		cout << "vrc = " << (int)pInput->intruder[i].vrc << endl;
		cout << "vsb = " << (int)pInput->intruder[i].vsb << endl;
		cout << "equipage = " << (int)pInput->intruder[i].equipage << endl;
		cout << "quant = " << (int)pInput->intruder[i].quant << endl;
		cout << "sensitivity_index = " << (int)pInput->intruder[i].sensitivity_index << endl;
		cout << "protection_mode = " << (int)pInput->intruder[i].protection_mode << endl;
	}
}

libccas_EXPORT void print_COutput(COutput cOutput)
{
	Output* pOutput = reinterpret_cast<Output*>(cOutput);
	cout << "Output" << endl;

	//Print Ownship
	cout << "Output:" << endl;
	cout << "cc = " << (int)pOutput->cc << endl;
	cout << "vc = " << (int)pOutput->vc << endl;
	cout << "ua = " << (int)pOutput->ua << endl;
	cout << "da = " << (int)pOutput->da << endl;
	cout << "target_rate = " << pOutput->target_rate << endl;
	cout << "turn_off_aurals = " << pOutput->turn_off_aurals << endl;
	cout << "crossing = " << pOutput->crossing << endl;
	cout << "alarm = " << pOutput->alarm << endl;
	cout << "alert = " << pOutput->alert << endl;
	cout << "dh_min = " << pOutput->dh_min << endl;
	cout << "dh_max = " << pOutput->dh_max << endl;
	cout << "sensitivity_index = " << (int)pOutput->sensitivity_index << endl;
	cout << "ddh = " << pOutput->ddh << endl;

	//Print intruders
	for (int i = 0; i < pOutput->intruder.size(); i++)
	{
		cout << "Intruder " << i << ":" << endl;
		cout << "id = " << (int)pOutput->intruder[i].id << endl;
		cout << "cvc = " << (int)pOutput->intruder[i].cvc << endl;
		cout << "vrc = " << (int)pOutput->intruder[i].vrc << endl;
		cout << "vsb = " << (int)pOutput->intruder[i].vsb << endl;
		cout << "tds = " << pOutput->intruder[i].tds << endl;
		cout << "code = " << (int)pOutput->intruder[i].code << endl;
	}
}

libccas_EXPORT const char* version(CCASShared cCASShared)
{
	CASShared* pCASShared = reinterpret_cast<CASShared*>(cCASShared);
	const char* ver = pCASShared->version();
	
	return ver;
}

libccas_EXPORT const char* error(CCASShared cCASShared)
{
	CASShared* pCASShared = reinterpret_cast<CASShared*>(cCASShared);

	return pCASShared->error();
}

libccas_EXPORT uint32 max_intruders(CCASShared cCASShared)
{
	CASShared* pCASShared = reinterpret_cast<CASShared*>(cCASShared);

	return (uint32)pCASShared->max_intruders();
}

libccas_EXPORT const char* author()
{
	const char* msg = "Written by Ritchie Lee\nritchie.lee@sv.cmu.edu";
	cout << msg << endl;

	return msg;
}

libccas_EXPORT int enum_EQUIPAGE_ATCRBS()
{
	return EQUIPAGE_ATCRBS;
}

libccas_EXPORT int enum_EQUIPAGE_MODES()
{
	return EQUIPAGE_MODES;
}

libccas_EXPORT int enum_EQUIPAGE_TCASTA()
{
	return EQUIPAGE_TCASTA;
}

libccas_EXPORT int enum_EQUIPAGE_TCAS()
{
	return EQUIPAGE_TCAS;
}

int main(int argc, const char* argv[])
{
	cout << "Starting..." << endl;
	cout << argv[0] << endl;

	cout << author() << endl;

	const char* config_filename = "../../../../libcas/parameters/0.8.3.standard.r13.config.txt";

	CConstants cConstants = newCConstants(25, config_filename, 1);

	const char* library_path = "../../../../libcas/lib/libcas.dll";

	CCASShared cCASShared = newCCASShared(cConstants, library_path);

	cout << "Version: " << version(cCASShared) << endl;
	cout << "Max_intruders: " << max_intruders(cCASShared) << endl;

	const char* errorMsg = error(cCASShared);
	if (errorMsg == NULL)
		cout << "No errors." << endl;
	else
		cout << "Error: " << errorMsg << endl;	

	CInput cInput = newCInput();

	COwnInput cOwnInput = getRefCOwnInput(cInput);

	CCollectionIntruderInput cIntruderInputs = getRefCCollectionIntruderInput(cInput);
	resizeCCollectionIntrInput(cIntruderInputs, 1);
	CIntruderInput cIntruderInput = getRefCIntruderInput(cIntruderInputs, 0);

	COutput cOutput = newCOutput();

	CCollectionIntruderOutput cIntruderOutputs = getRefCCollectionIntruderOutput(cOutput);
	resizeCCollectionIntrOutput(cIntruderOutputs, 1);
	CIntruderOutput cIntruderOutput = getRefCIntruderOutput(cIntruderOutputs, 0);
	setCIntrOutput_id(cIntruderOutput, 100);

	for (int i = 1; i <= 5; i++)
	{
		cout << endl;
		cout << "i = " << i << endl;

		reset(cCASShared);

		for (int t = 1; t <= 1; t++)
		{
			cout << "t = " << t << endl;
			//set input
			setCOwnInput(cOwnInput, 0.0, 36000.0, 0.0, 36000.0, 0x123);
			OwnInput* pOwnInput = reinterpret_cast<OwnInput*>(cOwnInput);
			Input* pInput = reinterpret_cast<Input*>(cInput);

			setCIntruderInput(cIntruderInput, false, 100,
				0x456, 10000.0, 0.0, 10000, 0x0, 0x0, 0x0, enum_EQUIPAGE_ATCRBS(),
				25, 0x0, 0x0);

			// update
			update(cCASShared, cInput, cOutput);

			//get output
			//cout << "[" << (int)getCOutput_cc(cOutput) << "," << (int)getCOutput_vc(cOutput) << ","
			//	<< (int)getCOutput_ua(cOutput) << "," << (int)getCOutput_da(cOutput) << "]" << endl;
			//cout << "target_rate=" << getCOutput_target_rate(cOutput) << endl;
			//cout << "dh_min=" << getCOutput_dh_min(cOutput) 
			//	<< ", dh_max=" << getCOutput_dh_max(cOutput) << endl;
			//cout << "ddh=" << getCOutput_ddh(cOutput) << endl;
		}
	}

	delCConstants(cConstants);
	delCCASShared(cCASShared);
	delCInput(cInput);
	delCOutput(cOutput);

	cout << endl;
	cout << "Done!" << endl;
	cout << "Press any key to continue..." << endl;
	getchar();
	return 0;
}

#ifdef  __cplusplus
}
#endif