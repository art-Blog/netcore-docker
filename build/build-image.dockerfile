# build/build-image.dockerfile
### build stage
FROM mcr.microsoft.com/dotnet/core/sdk:3.0 AS build
ARG project_name
COPY ./src ./src
WORKDIR /src
RUN dotnet publish $project_name -o /publish --configuration Release

### publish stage
FROM mcr.microsoft.com/dotnet/core/aspnet:3.0 AS runtime
ARG project_name
COPY --from=build /publish ./
ENV project_dll="${project_name}.dll"
ENTRYPOINT dotnet $project_dll