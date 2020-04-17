global with sharing class ExternalNlpServiceException extends Exception{

    private final ExternalNlpServiceExceptionCode exceptionCode;

    global ExternalNlpServiceException(String message, ExternalNlpServiceExceptionCode exceptionCode) {
        this(message);
        this.exceptionCode = exceptionCode;
    }

    global ExternalNlpServiceExceptionCode getExceptionCode() {
        return this.exceptionCode;
    }
}
