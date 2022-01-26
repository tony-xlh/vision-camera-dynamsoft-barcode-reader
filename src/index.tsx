import type { Frame } from 'react-native-vision-camera'

export interface TextResult{
    barcodeText:string;
    barcodeFormat:string;
    x1:number;
    x2:number;
    x3:number;
    x4:number;
    y1:number;
    y2:number;
    y3:number;
    y4:number;
}

export interface DBRConfig{
  template?:string;
  organizationID?:string;
  license?:string;
}



  export function decode(frame: Frame, config: DBRConfig): TextResult[] {
    'worklet'
    // @ts-ignore
    // eslint-disable-next-line no-undef
    return __decode(frame, config)
  }
