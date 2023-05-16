export type LambdaResponse = {
    ok: boolean;
    message: string;
    body?: LambdaResponseBody;
};

export type LambdaResponseBody = {
    items?: string;
};

export type ProductInfoMessage = {
    type: string;
};

export type ProductInfoResponse = {
    productInfo: ProductInfo;
};

export type RegisterMessage = {
    type: string;
    productInfo: ProductInfo;
};

export type RegisterResponse = LambdaResponse;

export type UnregisterMessage = {
    type: string;
    id: string;
};

export type UnregisterResponse = LambdaResponse;

export type ProductInfo = {
    id: string;
    title: string;
    price: number;
    point: number;
    url: string;
};

export type EnvVariables = {
    awsRegion: string;
    awsAccessKeyId: string;
    awsSecretAccessKey: string;
    awsApiEndpoint: string;
};
