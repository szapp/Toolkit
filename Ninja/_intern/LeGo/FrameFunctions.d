/***********************************\
            FRAMEFUNCTIONS
\***********************************/

//========================================
// [intern] PM-Klasse
//========================================
class FFItem {
    var int fncID;
    var int next;
    var int delay;
    var int cycles;
	var int data;
	var int hasData;
	var int gametime;
};
instance FFItem@(FFItem);

func void FFItem_Archiver(var FFItem this) {
    PM_SaveFuncPtr("loop", this.fncID);
    if(this.next)  { PM_SaveInt("next",  this.next); };
    if(this.delay) { PM_SaveInt("delay", this.delay); };
    if(this.cycles != -1) {
        PM_SaveInt("cycles", this.cycles);
    };
	if (this.hasData) { PM_SaveInt("data", this.data); };
	if (this.gametime) { PM_SaveInt("gametime", this.gametime); };
};

func void FFItem_Unarchiver(var FFItem this) {
    this.fncID = PM_LoadFuncPtr("loop");
    if(PM_Exists("next"))  { this.next = PM_Load("next"); };
    if(PM_Exists("delay")) { this.delay = PM_Load("delay"); };
    if(PM_Exists("cycles")) {
        this.cycles = PM_Load("cycles");
    }
    else {
        this.cycles = -1;
    };
	if (PM_Exists("data")) {
		this.data = PM_Load("data");
		this.hasData = 1;
	};

	if (PM_Exists("gametime")) {
		this.gametime = PM_Load("gametime");
	};
};

var int _FF_Symbol;

//========================================
// Non-persistent FrameFunctions (Ninja)
//========================================
const int _FF_arr = 0;
const int _FF_Create_Caller = 0;

//========================================
// Funktion hinzufügen
//========================================

func void _FF_Create(var func function, var int delay, var int cycles, var int hasData, var int data, var int gametime) {
    var FFItem itm;

    var int caller; caller = _FF_Create_Caller;
    _FF_Create_Caller = 0;
    if (!caller) {
        caller = MEM_GetFuncIDByOffset(MEM_GetCallerStackPos());
    };

    if (caller > Ninja_Symbols_Start)
    || (MEM_GetFuncID(function) > Ninja_Symbols_Start) {
        MEM_Info(ConcatStrings("NINJA: Creating non-persistent FrameFunction from ",
                               MEM_ReadString(MEM_GetSymbolByIndex(caller))));
        var int ffPtr; ffPtr = create(FFItem@);
        MEM_ArrayInsert(_FF_arr, ffPtr);
        itm = _^(ffPtr);
    } else {
        var int hndl; hndl = new(FFItem@);
        itm = get(hndl);
    };
    itm.fncID = MEM_GetFuncPtr(function);
    itm.cycles = cycles;
    itm.delay = delay;
	itm.data = data;
	itm.hasData = hasData;
	itm.gametime = gametime;
	if (gametime) {
		itm.next = TimerGT() + itm.delay;
	} else {
		itm.next = Timer() + itm.delay;
	};
};

func void FF_ApplyExtData(var func function, var int delay, var int cycles, var int data) {
    if (!_FF_Create_Caller) {
        _FF_Create_Caller = MEM_GetFuncIDByOffset(MEM_GetCallerStackPos());
    };
	_FF_Create(function, delay, cycles, true, data, false);
};

func void FF_ApplyExt(var func function, var int delay, var int cycles) {
    if (!_FF_Create_Caller) {
        _FF_Create_Caller = MEM_GetFuncIDByOffset(MEM_GetCallerStackPos());
    };
	_FF_Create(function, delay, cycles, false, 0, false);
};

func void FF_ApplyExtDataGT(var func function, var int delay, var int cycles, var int data) {
    if (!_FF_Create_Caller) {
        _FF_Create_Caller = MEM_GetFuncIDByOffset(MEM_GetCallerStackPos());
    };
	_FF_Create(function, delay, cycles, true, data, true);
};

func void FF_ApplyExtGT(var func function, var int delay, var int cycles) {
    if (!_FF_Create_Caller) {
        _FF_Create_Caller = MEM_GetFuncIDByOffset(MEM_GetCallerStackPos());
    };
	_FF_Create(function, delay, cycles, false, 0, true);
};

//========================================
// Funktion prüfen
//========================================
func int FF_Active(var func function) {
    _FF_Symbol = MEM_GetFuncPtr(function);
    foreachHndl(FFItem@, _FF_Active);
    if (_FF_Symbol) {
        repeat(i, MEM_ArraySize(_FF_arr)); var int i;
            if (MEM_ReadInt(MEM_ArrayRead(_FF_arr, i)) == _FF_Symbol) {
                _FF_Symbol = 0;
                break;
            };
        end;
    };
    return !_FF_Symbol;
};

func int _FF_Active(var int hndl) {
    if(MEM_ReadInt(getPtr(hndl)) != _FF_Symbol) {
        return continue;
    };
    _FF_Symbol = 0;
    return break;
};

//========================================
// Funktion hinzufügen (vereinfacht)
//========================================
func void FF_Apply(var func function) {
    if (!_FF_Create_Caller) {
        _FF_Create_Caller = MEM_GetFuncIDByOffset(MEM_GetCallerStackPos());
    };
    FF_ApplyExt(function, 0, -1);
};

func void FF_ApplyGT(var func function) {
    if (!_FF_Create_Caller) {
        _FF_Create_Caller = MEM_GetFuncIDByOffset(MEM_GetCallerStackPos());
    };
	FF_ApplyExtGT(function, 0, -1);
};

//========================================
// Funktion einmalig hinzufügen
//========================================
func void FF_ApplyOnceExt(var func function, var int delay, var int cycles) {
    if(FF_Active(function)) {
        _FF_Create_Caller = 0;
        return;
    };
    if (!_FF_Create_Caller) {
        _FF_Create_Caller = MEM_GetFuncIDByOffset(MEM_GetCallerStackPos());
    };
    FF_ApplyExt(function, delay, cycles);
};

func void FF_ApplyOnceExtGT(var func function, var int delay, var int cycles) {
    if(FF_Active(function)) {
        _FF_Create_Caller = 0;
        return;
    };
    if (!_FF_Create_Caller) {
        _FF_Create_Caller = MEM_GetFuncIDByOffset(MEM_GetCallerStackPos());
    };
    FF_ApplyExtGT(function, delay, cycles);
};

//========================================
// Funktion einmalig hinzufügen (vereinfacht)
//========================================
func void FF_ApplyOnce(var func function) {
    if (!_FF_Create_Caller) {
        _FF_Create_Caller = MEM_GetFuncIDByOffset(MEM_GetCallerStackPos());
    };
    FF_ApplyOnceExt(function, 0, -1);
};

//========================================
// Funktion entfernen
//========================================
func void FF_Remove(var func function) {
    _FF_Symbol = MEM_GetFuncPtr(function);
    foreachHndl(FFItem@, _FF_RemoveL);
    repeat(i, MEM_ArraySize(_FF_arr)); var int i;
        if (MEM_ReadInt(MEM_ArrayRead(_FF_arr, i)) == _FF_Symbol) {
            MEM_ArrayRemoveIndex(_FF_arr, i);
            break;
        };
    end;
};

func int _FF_RemoveL(var int hndl) {
    if(MEM_ReadInt(getPtr(hndl)) != _FF_Symbol) {
        return continue;
    };
    delete(hndl);
    return break;
};

func void FF_RemoveAll(var func function) {
    _FF_Symbol = MEM_GetFuncPtr(function);
    foreachHndl(FFItem@, _FF_RemoveAllL);
    repeat(i, MEM_ArraySize(_FF_arr)); var int i;
        if (MEM_ReadInt(MEM_ArrayRead(_FF_arr, i)) == _FF_Symbol) {
            MEM_ArrayRemoveIndex(_FF_arr, i);
        };
    end;
};

func int _FF_RemoveAllL(var int hndl) {
    if(MEM_ReadInt(getPtr(hndl)) != _FF_Symbol) {
        return continue;
    };
    delete(hndl);
    return continue;
};

//========================================
// [intern] Enginehook
//========================================
func void _FF_Hook() {
	if(!Hlp_IsValidNpc(hero)) { return; };

    foreachHndl(FFItem@, FrameFunctions);
    repeat(i, MEM_ArraySize(_FF_arr)); var int i;
        i;
        MEM_Call(FrameFunctions_Ptr);
    end;
};


func int FrameFunctions(var int hndl) {
    var FFItem itm; itm = get(hndl);

	var int timer;
    var int t; t = Timer();
	var int tgt; tgt = TimerGT();

	if (itm.gametime) {
		timer = tgt;
	} else {
		timer = t;
	};

    MEM_Label(0);
    if(timer >= itm.next) {
		if (itm.hasData) {
			itm.data;
		};
        MEM_CallByPtr(itm.fncID);

        // If a FrameFunction removes itself while its delay is small enough s.t. MEM_Goto(0) would be called below,
        // the game crashes, as MEM_CallByID calls an invalid symbol address.
        if (!Hlp_IsValidHandle(hndl)) {
            return rContinue;
        };

        if(itm.cycles != -1) {
            itm.cycles -= 1;
            if(itm.cycles <= 0) {
                delete(hndl);
                return rContinue;
            };
        };
        if(itm.delay) {
            itm.next += itm.delay;
            MEM_Goto(0);
        };
    };


    return rContinue;
};
func void FrameFunctions_Ptr(var int idx) {
    var int ffPtr; ffPtr = MEM_ArrayRead(_FF_arr, idx);
    var FFItem itm; itm = _^(ffPtr);

    var int timer;
    var int t; t = Timer();
    var int tgt; tgt = TimerGT();

    if (itm.gametime) {
        timer = tgt;
    } else {
        timer = t;
    };

    MEM_Label(0);
    if(timer >= itm.next) {
        if (itm.hasData) {
            itm.data;
        };
        MEM_CallByPtr(itm.fncID);

        // If a FrameFunction removes itself while its delay is small enough s.t. MEM_Goto(0) would be called below,
        // the game crashes, as MEM_CallByID calls an invalid symbol address.
        if (MEM_ArrayRead(_FF_arr, idx) != ffPtr) {
            return;
        };

        if(itm.cycles != -1) {
            itm.cycles -= 1;
            if(itm.cycles <= 0) {
                MEM_ArrayRemoveIndex(_FF_arr, idx);
                return;
            };
        };
        if(itm.delay) {
            itm.next += itm.delay;
            MEM_Goto(0);
        };
    };
};



/***********************************\
	The following code has been supplied by
	Frank-95 (https://forum.worldofplayers.de/forum/members/148085-Frank-95)
\***********************************/

//========================================
// Remove FF with the specified data
//========================================

var int _FF_Data;

func int _FF_RemoveLData(var int hndl)
{
    if(MEM_ReadInt(getPtr(hndl)) != _FF_Symbol)
    {
        return continue;
    };

    var FFItem itm; itm = get(hndl);
    if(itm.data != _FF_Data)
    {
        return continue;
    }
    else
    {
        delete(hndl);
        return break;
    };
};

func int _FF_RemoveLData_Ptr(var int idx)
{
    var FFItem itm; itm = _^(MEM_ArrayRead(_FF_arr, idx));
    if(itm.fncID != _FF_Symbol)
    {
        return FALSE;
    };

    if(itm.data != _FF_Data)
    {
        return FALSE;
    }
    else
    {
        MEM_ArrayRemoveIndex(_FF_arr, idx);
        return TRUE;
    };
};

func void FF_RemoveData(var func function, var int data)
{
    _FF_Data = data;
    _FF_Symbol = MEM_GetFuncPtr(function);
    foreachHndl(FFItem@, _FF_RemoveLData);
    repeat(i, MEM_ArraySize(_FF_arr)); var int i;
        if (_FF_RemoveLData_Ptr(i)) {
            break;
        };
    end;
};

//=======================================================
// Check whether FF with the specified data is active
//=======================================================


func int _FF_ActiveData(var int hndl)
{
    if(MEM_ReadInt(getPtr(hndl)) != _FF_Symbol)
    {
        return continue;
    };

    var FFItem itm; itm = get(hndl);
    if(itm.data != _FF_Data)
    {
        return continue;
    }
    else
    {
        _FF_Symbol = 0;
        return break;
    };
};
func int _FF_ActiveData_Ptr(var int idx)
{
    var FFItem itm; itm = _^(MEM_ArrayRead(_FF_arr, idx));
    if(itm.fncID != _FF_Symbol)
    {
        return FALSE;
    };

    if(itm.data != _FF_Data)
    {
        return FALSE;
    }
    else
    {
        _FF_Symbol = 0;
        return TRUE;
    };
};

func int FF_ActiveData(var func function, var int data)
{
    _FF_Data = data;
    _FF_Symbol = MEM_GetFuncPtr(function);
    foreachHndl(FFItem@, _FF_ActiveData);
    if (_FF_Symbol) {
        repeat(i, MEM_ArraySize(_FF_arr)); var int i;
            if (_FF_ActiveData_Ptr(i)) {
                break;
            };
        end;
    };
    return !_FF_Symbol;
};

//========================================
// More FFdata functions
//========================================

func void FF_ApplyData(var func function, var int data)
{
    if (!_FF_Create_Caller) {
        _FF_Create_Caller = MEM_GetFuncIDByOffset(MEM_GetCallerStackPos());
    };
    FF_ApplyExtData(function, 0, -1, data);
};

func void FF_ApplyOnceExtData(var func function, var int delay, var int cycles, var int data)
{
    if(FF_ActiveData(function,data))
    {
        _FF_Create_Caller = 0;
        return;
    };

    if (!_FF_Create_Caller) {
        _FF_Create_Caller = MEM_GetFuncIDByOffset(MEM_GetCallerStackPos());
    };
    FF_ApplyExtData(function, delay, cycles, data);
};

func void FF_ApplyOnceData(var func function, var int data)
{
    if (!_FF_Create_Caller) {
        _FF_Create_Caller = MEM_GetFuncIDByOffset(MEM_GetCallerStackPos());
    };
    FF_ApplyOnceExtData(function, 0, -1, data);
};


