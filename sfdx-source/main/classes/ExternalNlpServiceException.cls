public with sharing class ExternalNlpServiceException extends Exception{

    private final ExternalNlpServiceExceptionCode exceptionCode;

    public ExternalNlpServiceException(String message, ExternalNlpServiceExceptionCode exceptionCode) {
        this(message);
        this.exceptionCode = exceptionCode;
    }

    public ExternalNlpServiceExceptionCode getExceptionCode() {
        return this.exceptionCode;
    }
}
