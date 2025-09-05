# Material Rental Application

This is a Material Rental Application built with a Node.js Express backend and a Flutter frontend. The application allows users to rent materials, view details, and manage rental requests. Admin users have additional functionalities to add materials and approve rental requests.

## Features

- User-friendly interface for browsing and renting materials.
- QR code generation for each material.
- Admin functionalities for managing materials and rental requests.
- API documentation available via Swagger.

## Technologies Used

- **Backend**: Node.js, Express, MongoDB
- **Frontend**: Flutter
- **Database**: MongoDB
- **API Documentation**: Swagger

## Getting Started

### Prerequisites

- Node.js and npm installed
- MongoDB installed and running
- Flutter SDK installed

### Backend Setup

1. Navigate to the backend directory:
   ```
   cd backend
   ```

2. Install dependencies:
   ```
   npm install
   ```

3. Set up the MongoDB connection in `src/config/db.js`.

4. Start the backend server:
   ```
   npm start
   ```

### Frontend Setup

1. Navigate to the frontend directory:
   ```
   cd frontend
   ```

2. Install Flutter dependencies:
   ```
   flutter pub get
   ```

3. Run the Flutter application:
   ```
   flutter run
   ```

## API Documentation

API endpoints are documented using Swagger. You can access the documentation at `http://localhost:5000/api-docs` after starting the backend server.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any enhancements or bug fixes.

## License

This project is licensed under the MIT License. See the LICENSE file for details.