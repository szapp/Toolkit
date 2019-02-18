/*
 * Determine whether to exclude a symbol from PermMem
 */
func int _PM_ExcludeSymbol(var int ID) {
    const int LeGo_Symbols_Start = -1;
    const int LeGo_Symbols_End   = -1;
    if (LeGo_Symbols_Start < 0) {
        LeGo_Symbols_Start = MEM_GetSymbolIndex("_LEGO_FLAGS");
        LeGo_Symbols_End   = MEM_GetSymbolIndex("LEGO_INIT");
    };

    // Symbol from DAT or within LeGo
    if (ID < Ninja_Symbols_Start) || ((ID > LeGo_Symbols_Start) && (ID < LeGo_Symbols_End)) {
        return FALSE;
    } else {
        return TRUE;
    };
};
