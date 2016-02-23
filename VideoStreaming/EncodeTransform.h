#ifndef _ENCODE_TRANSFORM_H_
#define _ENCODE_TRANSFORM_H_

#include "Includes.h"
#include <Propvarutil.h>

struct EncoderOutput
{
	byte		*pEncodedData;
	DWORD		numBytes;
	LONGLONG	timestamp;
	LONGLONG	duration;
	HRESULT		returnCode;
};


class EncodeTransform 
{
public:
	bool mbEncodeBackgroundPixels = false;

	EncodeTransform();

	void Init(int width, int height);
	EncoderOutput EncodeData(char *pInputData, size_t numBytesInput);
	HRESULT Unlock();
	int GetStreamWidth() const { return mStreamWidth; }
	int GetStreamHeight() const { return mStreamHeight; }
	void Shutdown();
	void SetEncodingThreshold(int threshold) { mEncodingThreshold = threshold; }

private:
	HRESULT QueryStreamCapabilities();
	HRESULT FindEncoder(const GUID& subtype);
	HRESULT SetInputMediaType();
	HRESULT SetOutputMediaType();
	HRESULT QueryInputStreamInfo();
	HRESULT QueryOutputStreamInfo();
	HRESULT ProcessInput();
	HRESULT ProcessOutput(EncoderOutput& etn);
	HRESULT AddSample(const LONGLONG& rtStart);
	HRESULT SendStreamStartMessage();
	HRESULT SendStreamEndMessage();
	HRESULT CommandDrain();


	DWORD* mCompressedBuffer = NULL;
	
	IMFTransform *mpEncoder = NULL; // pointer to the encoder MFT

	MFT_INPUT_STREAM_INFO	mInputStreamInfo;
	MFT_OUTPUT_STREAM_INFO	mOutputStreamInfo;

	const GUID   cVideoEncodingFormat	= MFVideoFormat_H264;
	const GUID   cVideoInputFormat		= MFVideoFormat_YUY2;

	ICodecAPI *mpCodecAPI = NULL;

	// Store stream limit info to determine pipeline capabailities
	DWORD mInputStreamMin = 0;
	DWORD mInputStreamMax = 0;
	DWORD mOutputStreamMin = 0;
	DWORD mOutputStreamMax = 0;

	// Stream IDs for input and output streams
	DWORD mInputStreamID = 0;
	DWORD mOutputStreamID = 0;

	boolean mInputComplete = false;
	LONGLONG mTimeStamp = 0;
	IMFMediaBuffer *mpInputBuffer = NULL;
	IMFMediaBuffer *mpEncodedBuffer = NULL;
	IMFSample *pSampleProcIn = NULL;
	IMFSample *pSampleProcOut = NULL;
	int mStreamWidth;
	int mStreamHeight;
	int mEncodingThreshold;
};
#endif // _ENCODE_TRANSFORM_H_