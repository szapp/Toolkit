/*
 * Ninja: Exclude handles containing symbols specific to a Ninja patch, i.e. symbID > Ninja_Symbols_Start
 */
func int _PM_SkipHandle(var int key, var int val) {
    // Do not exclude LeGo symbols if LeGo is not part of mod
    var int skipThreshold; skipThreshold = Ninja_Symbols_Start;
    if (MEM_GetSymbolIndex("LEGO_INIT") > Ninja_Symbols_Start) {
        skipThreshold = MEM_GetSymbolIndex("LEGO_INIT");
    };

    var int inst; inst = _HT_Get(HandlesInstance, key);
    var int symbID;
    var zCPar_Symbol symb;
    var zCPar_Symbol symbClass; symbClass = _PM_ToClass(inst);
    var string instName; instName = _PM_InstName(inst);
    var string className; className = symbClass.name;
    if (!STR_Compare(instName, "FFITEM@")) {
        var FFItem ff; ff = get(key);
        symbID = MEM_GetFuncIDByOffset(ff.fncID - currParserStackAddress);
        if (symbID > skipThreshold) {
            symb = _^(MEM_GetSymbolByIndex(symbID));
            MEM_SendToSpy(zERR_TYPE_WARN, ConcatStrings("NINJA: Skipping FFItem of ", symb.name));
            return TRUE;
        };
    } else if (!STR_Compare(instName, "A8HEAD@")) {
        var A8Head a8; a8 = get(key);
        if (a8.fnc) {
            symbID = MEM_GetFuncIDByOffset(a8.fnc - currParserStackAddress);
            if (symbID > skipThreshold) {
                symb = _^(MEM_GetSymbolByIndex(symbID));
                MEM_SendToSpy(zERR_TYPE_WARN, ConcatStrings("NINJA: Skipping A8Head of ", symb.name));
                return TRUE;
            };
        };
        if (a8.dfnc) {
            symbID = MEM_GetFuncIDByOffset(a8.dfnc - currParserStackAddress);
            if (symbID > skipThreshold) {
                symb = _^(MEM_GetSymbolByIndex(symbID));
                MEM_SendToSpy(zERR_TYPE_WARN, ConcatStrings("NINJA: Skipping A8Head of ", symb.name));
                return TRUE;
            };
        };
    } else if (!STR_Compare(instName, "_BUTTON@")) {
        var _Button bt; bt = get(key);
        if (bt.on_enter > skipThreshold)
        || (bt.on_leave > skipThreshold)
        || (bt.on_click > skipThreshold) {
            symb = _^(MEM_GetSymbolByIndex(bt.on_click));
            MEM_SendToSpy(zERR_TYPE_WARN, ConcatStrings("NINJA: Skipping _Button of ", symb.name));
            return TRUE;
        };
    } else if (!STR_Compare(instName, "CALLBACKDATA@")) {
        var callbackData cb; cb = get(key);
        if (cb.funcID > skipThreshold) {
            symb = _^(MEM_GetSymbolByIndex(cb.funcID));
            MEM_SendToSpy(zERR_TYPE_WARN, ConcatStrings("NINJA: Skipping callbackData of ", symb.name));
            return TRUE;
        };
    } else if (!STR_Compare(instName, "RENDERITEM@")) {
        var RenderItem ri; ri = get(key);
        if (ri.inst > skipThreshold) {
            symb = _^(MEM_GetSymbolByIndex(ri.inst));
            MEM_SendToSpy(zERR_TYPE_WARN, ConcatStrings("NINJA: Skipping RenderItem of ", symb.name));
            return TRUE;
        };
    } else if (!STR_Compare(className, "LCBUFF")) {
        var lCBuff bf; bf = get(key);
        if (bf.OnApply > skipThreshold)
        || (bf.OnTick > skipThreshold)
        || (bf.OnRemoved > skipThreshold) {
            symb = _^(MEM_GetSymbolByIndex(bf.OnTick));
            MEM_SendToSpy(zERR_TYPE_WARN, ConcatStrings("NINJA: Removing lCBuff of ", symb.name));
            FF_RemoveData(_Buff_Dispatcher, key);
            Buff_Remove(key);
            return TRUE;
        };
    };
    return FALSE;
};
