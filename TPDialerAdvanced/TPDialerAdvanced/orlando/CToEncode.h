#ifndef TOENCODE_H_INCLUDED
#define TOENCODE_H_INCLUDED

#define ERROR_INIT_FAILE -1
#define ERROR_NOT_INIT -2
#define ERROE_BUFFER_SIZE_NO_ENOUGH -3

class CToEncode{
    public:
       virtual int enCode(
            short *encoded_data,
            int encoded_data_size,
            short *speech_data,
            int cSample);

        virtual int deCode(
            short *encoded_data,
            int encodedDataSize,
            short *data,  
            int data_size
        );

        virtual int InitEncode(int mod);
        virtual void DeinitEncode();
        virtual int InitDecode(int mod);
        virtual void DeinitDecode();
        CToEncode();
        ~CToEncode();
       private:
            void *Enc_Inst;
            void *Dec_Inst;
            int enmode;
            int demode;
            int enpacksize;
            int depacksize;

};




#endif // TOENCODE_H_INCLUDED
