int combineFlags(List<int> flags) => flags.fold(0, (memo, flag) => memo | flag);
