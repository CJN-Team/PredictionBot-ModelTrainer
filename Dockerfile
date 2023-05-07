#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["PredictionBot-ModelTrainer/PredictionBot-ModelTrainer.csproj", "PredictionBot-ModelTrainer/"]
COPY ["PredictionBot-ModelTrainer-Application/PredictionBot-ModelTrainer-Application.csproj", "PredictionBot-ModelTrainer-Application/"]
COPY ["PredictionBot-ModelTrainer-Infrastructure/PredictionBot-ModelTrainer-Infrastructure.csproj", "PredictionBot-ModelTrainer-Infrastructure/"]
COPY ["PredictionBot-ModelTrainer-Domain/PredictionBot-ModelTrainer-Domain.csproj", "PredictionBot-ModelTrainer-Domain/"]

RUN dotnet restore "PredictionBot-ModelTrainer/PredictionBot-ModelTrainer.csproj"
COPY . .
WORKDIR "/src/PredictionBot-ModelTrainer"
RUN dotnet build "PredictionBot-ModelTrainer.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "PredictionBot-ModelTrainer.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "PredictionBot-ModelTrainer.dll"]