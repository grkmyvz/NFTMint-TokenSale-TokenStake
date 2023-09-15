export function createMulticall(contractParams: any, params: string[]) {
  const multicall = [];
  for (const param of params) {
    multicall.push({
      ...contractParams,
      functionName: param,
    });
  }
  return multicall;
}
