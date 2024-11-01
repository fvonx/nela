# README

## Addressing Innovation in Textual Communication

**Addressing Innovation in Textual Communication.** We believe the primary reason email client innovation has stagnated is the overwhelming complexity of the underlying infrastructure and protocols. Building new clients has become exceptionally time-consuming. That's why email clients from 2000 look remarkably similar to those in 2024. Nela is here to change that. By streamlining the development process, Nela paves the way for faster, more secure advancements in text-based communication.

To send and receive messages with Nela, all you need to do is implement two API endpoints — Nela handles message reception, while the rest is up to you. The protocol stays out of your way:

1. POST /nela/messages – for receiving messages
2. PUT /nela/messages/<message_ref>/handshakes/<handshake_ref> – to confirm the existence of the sender and message

## Overview

The Nela protocol facilitates secure communication between systems by leveraging digital signatures and certificates to verify message authenticity. It is specifically designed to handle message delivery in environments where ensuring message integrity, sender authenticity, and message routing between multiple parties are crucial. Nela aims to provide an easy-to-use API structure for interacting systems while maintaining high security standards.

## Key Concepts

### Digital Signatures

Messages sent through the Nela protocol are digitally signed to ensure authenticity and integrity. The sender signs the message with a private key, and the recipient verifies it using the corresponding public key. This mechanism ensures that:

1. The message has not been altered during transit.
2. The message genuinely comes from the claimed sender.

### Certificate Validation

Certificates are used to verify the sender's identity. Each sender provides a certificate in PEM format along with each message, which allows the recipient to validate the authenticity of the message.

### Message Structure

Messages follow a JSON-based structure that includes information about the sender, receiver, content, and reference details for context.

```
{
  "message": {
    "title": "Hello World",
    "body": "Nice to meet you",
    "sender": "matthias@withnela.com",
    "direct_receiver": "lou@withnela.com",
    "all_receivers": ["lou@withnela.com", "clara@withnela.com"],
    "conversation_ref": "b3222267-5e86-4a05-9f07-ead7c85bc580",
    "message_ref": "cb97a34f-dadf-4579-9a55-485f1cc2c68c",
    "handshake_ref": "851a8754-6887-4b3f-8553-fdd779d8baa4"
  }
}
```

### Handshake Mechanism

The handshake mechanism guarantees that a message was deliberately transmitted by the sender and is genuinely present within their infrastructure. This process enables the receiver to authenticate the sender's identity and confirm that the message has not been fabricated or impersonated.

1. **Sender**: Send the message with a `handshake_ref`.
2. **Receiver**: Send a handshake request to the sender including the `handshake_ref`.
3. **Receiver**: Flag the message as valid (or drop otherwise) if it exists on the sender's infrastructure, ensuring that the sender address has not been manipulated.

### Security Model

**Signature Verification**: Each message includes a digital signature (`signature_base64`) that is verified by the receiver using the public certificate.

**Expected Domain Matching**: The `sender` field is validated against the domain presented in the certificate to ensure consistency and guard against impersonation attacks.

## Endpoints

### Receive Messages

The `/nela/messages` endpoint allows authorized systems to send messages to the Nela protocol server.

#### Request

- **URL**: `/nela/messages`
- **Method**: `POST`
- **Parameters**:
  - `signature` (required): The base64-encoded digital signature of the message.
  - `certificate` (required): The PEM-encoded certificate of the sender.
  - `message` (all attributes required): The message body (please find example below).

#### Response Codes

- `201 Created`: Message received successfully.
- `422 Unprocessable Entity`: Missing or invalid signature/certificate.
- `401 Unauthorized`: Signature verification failed.

#### Example Request

```
curl -X POST "https://nela.example.com/nela/messages" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "title": "Hello World",
      "body": "Nice to meet you",
      "sender": "matthias@withnela.org",
      "direct_receiver": "lou@withnela.org",
      "all_receivers": ["lou@withnela.org", "clara@withnela.org"],
      "conversation_ref": "b3222267-5e86-4a05-9f07-ead7c85bc580",
      "message_ref": "cb97a34f-dadf-4579-9a55-485f1cc2c68c",
      "handshake_ref": "851a8754-6887-4b3f-8553-fdd779d8baa4"
    },
    "signature": "(Base64-encoded signature)",
    "certificate": "(PEM-encoded certificate)"
  }'
```

### Handshake Incoming Messages

The `/nela/messages/<message_ref>/handshakes/<handshake_ref>` endpoint allows the receiver to confirm that the message has not been fabricated or impersonated.

#### Request

- **URL**: `/nela/messages/<message_ref>/handshakes/<handshake_ref>`
- **Method**: `PUT`
- **Parameters**:
  - `signature` (required): The base64-encoded digital signature of the message.
  - `certificate` (required): The PEM-encoded certificate of the sender.
  - `message` (all attributes required): The message body (please find example below).

#### Response Codes

- `200 Ok`: Message successfully handshaked.
- `404 Not Found`: Invalid message
- `401 Unauthorized`: Signature verification failed.

#### Example Request

```
curl -X PUT "https://nela.example.com/nela/messages/<message_ref>/handshakes/<handshake_ref>" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "sender": "matthias@withnela.org",
      "direct_receiver": "lou@withnela.org",
      "conversation_ref": "b3222267-5e86-4a05-9f07-ead7c85bc580",
      "message_ref": "cb97a34f-dadf-4579-9a55-485f1cc2c68c",
      "handshake_ref": "851a8754-6887-4b3f-8553-fdd779d8baa4"
    },
    "signature": "(Base64-encoded signature)",
    "certificate": "(PEM-encoded certificate)"
  }'
```

## Signature and Certificate Verification Flow

1. **Extract Signature and Certificate**: The `signature` and `certificate` parameters are extracted from the incoming request.
2. **Validate Certificate**: Ensure that the provided certificate is valid and that the domain matches the expected sender.
3. **Verify Digital Signature**: Use the extracted certificate to verify that the digital signature matches the message data.
4. **Accept or Reject the Message**: If verification succeeds, the message is accepted and processed. Otherwise, an error response is returned.

## Error Handling

- **Invalid Signature or Certificate**: If the signature or certificate is invalid, an HTTP status of `401 Unauthorized` will be returned.
- **Missing Parameters**: If either the signature or certificate is missing, an HTTP status of `422 Unprocessable Entity` will be returned.

## Example Implementation Workflow

1. The client must sign the message payload and attach the base64-encoded signature.
2. The client attaches the certificate in PEM format to allow the recipient to verify authenticity.
3. The server verifies the signature using the provided certificate.
4. If verification passes, the message is processed and saved in the database; otherwise, an appropriate error code is returned.

## Notes on Implementation

- Ensure that the private keys are securely stored and never exposed.
- The signature verification should use the appropriate cryptographic library to prevent any vulnerability exploitation.
- Certificates should be periodically rotated, and the public key should be verified against trusted authorities when possible.

## Creating a self signed certificate for development purposes

1. **Navigate to a Secure Directory:**

`cd /path/to/your/project/config/ssl`

2. **Generate a Private Key:**

`openssl genrsa -out dev_privkey.pem 2048`

3. **Create a Self-Signed Certificate:**

`openssl req -new -x509 -key dev_privkey.pem -out dev_cert.pem -days 365 -subj "/CN=neladev.com"`

4. **Verify the Certificate and Key:**

`openssl x509 -in dev_cert.pem -text -noout`

## Summary

The Nela protocol is built to ensure secure communication between different systems by leveraging digital signatures and certificates for verification. With robust authentication and validation mechanisms in place, it prevents data tampering and ensures sender authenticity. The handshake mechanism adds an additional layer of security by establishing a trusted session before message exchange.