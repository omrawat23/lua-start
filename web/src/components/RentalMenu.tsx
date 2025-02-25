"use client";

import type React from "react";
import { useState, useEffect } from "react";
import { fetchNui, useNuiEvent } from "@utilities/utils";
import { Car, X, ArrowRight, Zap, Star } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { ScrollArea } from "@/components/ui/scroll-area";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { Label } from "@/components/ui/label";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { cn } from "@/lib/utils";

interface Color {
  name: string;
  value: string;
}

interface Vehicle {
  id: string;
  model: string;
  price: number;
  image: string;
  seats: number;
  speed: string;
  efficiency: string;
  colors: Color[];
  type: string;
}

interface Category {
  name: string;
  vehicles: Vehicle[];
}

interface RentalData {
  coords: { x: number; y: number; z: number };
  ped: { name: string };
  blip: any;
  spawnpoint: { x: number; y: number; z: number; w: number };
  categories: Category[];
  type: string;
}

const RentalMenu: React.FC = () => {
  const [visible, setVisible] = useState<boolean>(false);
  const [rentalData, setRentalData] = useState<RentalData | null>(null);
  const [selectedCar, setSelectedCar] = useState<Vehicle | null>(null);
  const [selectedColor, setSelectedColor] = useState<Color | null>(null);
  const [paymentMethod, setPaymentMethod] = useState<"cash" | "bank">("cash");
  const [activeCategory, setActiveCategory] = useState<string>("Bicycles");
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState<string>("");

  useEffect(() => {
    const handleEscape = (event: KeyboardEvent) => {
      if (event.key === "Escape") {
        closeUI();
      }
    };

    window.addEventListener("keydown", handleEscape);
    return () => window.removeEventListener("keydown", handleEscape);
  }, []);

  useNuiEvent("openRentalMenu", (data: RentalData) => {
    console.log("Received rental data in NUI:", data);
    setRentalData(data);
    setVisible(true);
    setError(null);
    if (data.categories.length > 0) {
      setActiveCategory(data.categories[0].name);
    }
  });

  const closeUI = () => {
    setLoading(true);
    fetchNui("closeRentalMenu")
      .then(() => {
        console.log("Rental menu closed");
        setVisible(false);
      })
      .catch((error) => {
        console.error("Failed to close rental menu:", error);
        setError("Failed to close menu. Please try again.");
      })
      .finally(() => setLoading(false));
  };

  const handleCarSelect = (vehicle: Vehicle) => {
    setSelectedCar(vehicle);
    setSelectedColor(vehicle.colors[0]);
  };

  const filteredVehicles = () => {
    if (!rentalData) return [];

    const category = rentalData.categories.find(
      (c) => c.name === activeCategory
    );
    if (!category) return [];

    return category.vehicles.filter((vehicle) =>
      vehicle.model.toLowerCase().includes(searchQuery.toLowerCase())
    );
  };

  const rentVehicle = (vehicle: Vehicle) => {
    if (!selectedColor) {
      setError("Please select a color for your vehicle");
      return;
    }

    if (!paymentMethod) {
      setError("Please select a payment method");
      return;
    }

    const isValidColor = vehicle.colors.some(
      (color) => color.value === selectedColor.value
    );
    if (!isValidColor) {
      setError("Invalid color selection for this vehicle");
      return;
    }

    setLoading(true);
    setError(null);

    fetchNui("rental:rentVehicle", {
      model: vehicle.model,
      price: vehicle.price,
      rental: rentalData,
      color: selectedColor.value,
      paymentMethod: paymentMethod,
    })
      .then(() => {
        console.log(
          `Vehicle rented: ${vehicle.model} with color ${selectedColor.value}`
        );
        // Add a small delay before closing the UI
        setTimeout(() => {
          setVisible(false);
        }, 50); // 50ms delay
      })
      .catch((error) => {
        console.error("Error renting vehicle:", error);
        setError("Failed to rent vehicle. Please try again.");
      })
      .finally(() => setLoading(false));
  };

  const returnVehicle = () => {
    setLoading(true);
    fetchNui("rental:returnVehicle")
      .then(() => {
        console.log("Vehicle returned");
        setVisible(false);
      })
      .catch((error) => {
        console.error("Error returning vehicle:", error);
        setError("Failed to return vehicle. Please try again.");
      })
      .finally(() => setLoading(false));
  };

  if (!visible) return null;

  return (
    <div className="fixed inset-0 flex items-center justify-center z-50">
      <div className="relative w-full max-w-[85vw] max-h-[85vh] overflow-hidden rounded-xl border border-cyan-500/50 shadow-2xl shadow-cyan-500/20">
        <div className="absolute inset-0">
          <div className="absolute inset-0 bg-black/90 z-0" />
          <div
            className="absolute inset-0 bg-cover bg-center bg-no-repeat opacity-20 z-1"
            style={{
              backgroundImage:
                "url('https://img.freepik.com/free-vector/abstract-futuristic-background_23-2148397048.jpg?t=st=1739530140~exp=1739533740~hmac=5020f507dce70dfd58c5447e3c18dbba78225cd8f0a21007d7ebba4b351bbc70&w=1380')",
            }}
          />
          <div className="absolute inset-0 bg-gradient-to-br from-cyan-950/20 via-gray-900/40 to-blue-950/20 animate-gradient z-2" />
          <div className="absolute inset-0 bg-[radial-gradient(circle_at_50%_50%,rgba(0,200,255,0.1),transparent_70%)] z-3" />
          <div className="absolute inset-0 bg-grid-pattern opacity-10 z-4" />
        </div>

        <div className="relative z-10">
          <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-transparent via-cyan-500/50 to-transparent" />

          <div className="relative flex justify-between items-center px-6 py-4 bg-gradient-to-r from-gray-900/90 via-gray-800/90 to-gray-900/90 border-b border-cyan-700/50">
            <h2 className="rowdies-regular text-3xl text-cyan-400 flex items-center gap-3">
              <Zap className="text-yellow-400 animate-pulse" />
              <span className="bg-gradient-to-r from-cyan-400 to-blue-400 text-transparent bg-clip-text">
                Cyber Rentals
              </span>
            </h2>
            <Button
              variant="ghost"
              size="icon"
              onClick={closeUI}
              className="text-cyan-400 hover:text-cyan-300 hover:bg-cyan-950/50 transition-all duration-300"
            >
              <X className="h-6 w-6" />
            </Button>
          </div>

          <div className="flex flex-row h-[calc(90vh-100px)]">
            <div className="w-3/4 p-6 border-r border-cyan-700">
              {error && (
                <div className="mb-4 p-3 bg-red-900 text-red-100 rounded">
                  {error}
                </div>
              )}

              <div className="mb-6 space-y-4">
                <div className="flex justify-start">
                  <Tabs value={activeCategory} onValueChange={setActiveCategory}>
                    <div className="flex gap-2 bg-gray-800 h-12 p-2 rounded-xl border border-cyan-700">
                      {rentalData?.categories.map((category) => (
                        <button
                          key={category.name}
                          onClick={() => setActiveCategory(category.name)}
                          className={cn(
                            "px-6 py-1 rounded-lg rowdies-regular text-sm transition-all",
                            "hover:bg-gray-700 hover:text-cyan-400",
                            activeCategory === category.name
                              ? "bg-cyan-900 text-cyan-400 shadow-sm font-bold"
                              : "bg-transparent text-gray-400",
                            "whitespace-nowrap flex-shrink-0"
                          )}
                        >
                          {category.name}
                        </button>
                      ))}
                    </div>
                  </Tabs>
                </div>
              </div>

              <ScrollArea className="h-[calc(100%-120px)]">
                <div className="grid grid-cols-3 md:grid-cols-3 lg:grid-cols-3 gap-4 pr-4">
                  {filteredVehicles().map((vehicle, index) => (
                    <Card
                      key={index}
                      className="overflow-hidden border-0 bg-gray-800 hover:bg-gray-700 transition-all duration-300 transform"
                    >
                      <CardContent className="p-4">
                        <div className="aspect-video relative mb-4 overflow-hidden rounded-lg">
                          <img
                            src={vehicle.image || "/placeholder.svg"}
                            alt={vehicle.model}
                            className="w-full h-full object-cover transition-transform duration-300 transform hover:scale-110"
                          />
                        </div>
                        <h3 className="rowdies-regular text-lg text-cyan-400 mb-2">
                          {vehicle.model}
                        </h3>
                        <div className="flex items-center justify-between mb-2">
                          <p className="poppins-regular text-xl text-yellow-400">
                            ${vehicle.price}
                          </p>
                        </div>
                        <Button
                          onClick={() => handleCarSelect(vehicle)}
                          variant="secondary"
                          size="sm"
                          className="w-full h-10 bg-cyan-700 text-cyan-100 text-sm rowdies-bold rounded-lg hover:bg-cyan-600 transition-colors"
                        >
                          Select
                        </Button>
                      </CardContent>
                    </Card>
                  ))}
                </div>
              </ScrollArea>
            </div>

            <div className="w-1/4 p-6 max-w-[600px] overflow-hidden">
              <ScrollArea className="h-full">
                {selectedCar ? (
                  <div className="space-y-4">
                    <Card className="bg-gray-800 hover:bg-gray-700 border-0 shadow-lg ">
                      <CardContent className="p-4 space-y-4">
                        <div className="relative aspect-video bg-gray-800 rounded-lg overflow-hidden">
                          <img
                            src={selectedCar.image || "/placeholder.svg"}
                            alt={selectedCar.model}
                            className="object-cover w-full h-full"
                          />
                        </div>
                        <div>
                          <h3 className="rowdies-regular text-lg text-cyan-400">
                            {selectedCar.model}
                          </h3>
                          <p className="poppins-regular text-2xl text-yellow-400">
                            ${selectedCar.price}
                          </p>
                        </div>
                        <div className="space-y-4">
                          <div>
                            <p className="rowdies-light text-sm mb-2 text-cyan-300">
                              Available Colors
                            </p>
                            <div className="flex flex-wrap gap-2">
                              {selectedCar.colors.map((color) => (
                                <button
                                  key={color.value}
                                  onClick={() => setSelectedColor(color)}
                                  className={cn(
                                    "w-8 h-8 rounded-full transition-all duration-200",
                                    "hover:scale-105 hover:shadow-lg",
                                    color.value === selectedColor?.value
                                      ? "ring-2 ring-cyan-400 ring-offset-2 scale-105 border-2 border-cyan-200"
                                      : "border-2 border-gray-600 hover:border-cyan-400"
                                  )}
                                  style={{
                                    backgroundColor: color.value,
                                    boxShadow:
                                      color.value === selectedColor?.value
                                        ? "0 0 10px rgba(6, 182, 212, 0.5)"
                                        : "none",
                                  }}
                                  aria-label={`Select ${color.name}`}
                                  title={color.name}
                                >
                                  <span className="sr-only">{color.name}</span>
                                </button>
                              ))}
                            </div>
                          </div>
                          <div>
                            <p className="rowdies-light text-sm mb-2 text-cyan-300">
                              Payment Method
                            </p>
                            <RadioGroup
                              value={paymentMethod}
                              onValueChange={(value) =>
                                setPaymentMethod(value as "cash" | "bank")
                              }
                              className="grid grid-cols-2 gap-4"
                            >
                              <div className="relative">
                                <RadioGroupItem
                                  value="cash"
                                  id="cash"
                                  className="peer sr-only"
                                />
                                <Label
                                  htmlFor="cash"
                                  className={cn(
                                    "flex flex-col items-center justify-between rounded-md border-2 p-4",
                                    "cursor-pointer transition-all",
                                    "hover:bg-gray-600",
                                    paymentMethod === "cash"
                                      ? "border-cyan-400 bg-cyan-900"
                                      : "border-gray-600"
                                  )}
                                >
                                  <div className="flex items-center space-x-2">
                                    <span className="rowdies-regular text-cyan-300">
                                      Cash
                                    </span>
                                  </div>
                                </Label>
                              </div>
                              <div className="relative">
                                <RadioGroupItem
                                  value="bank"
                                  id="bank"
                                  className="peer sr-only"
                                />
                                <Label
                                  htmlFor="bank"
                                  className={cn(
                                    "flex flex-col items-center justify-between rounded-md border-2 p-4",
                                    "cursor-pointer transition-all",
                                    "hover:bg-gray-600",
                                    paymentMethod === "bank"
                                      ? "border-cyan-400 bg-cyan-900"
                                      : "border-gray-600"
                                  )}
                                >
                                  <div className="flex items-center space-x-2">
                                    <span className="rowdies-regular text-cyan-300">
                                      Bank
                                    </span>
                                  </div>
                                </Label>
                              </div>
                            </RadioGroup>
                          </div>
                          <div className="pt-4 border-t border-cyan-700">
                            <Button
                              className="w-full h-12 bg-cyan-600 text-cyan-100 text-sm rowdies-bold rounded-lg hover:bg-cyan-500 transition-colors"
                              onClick={() => rentVehicle(selectedCar)}
                              disabled={loading}
                            >
                              {loading ? "Processing..." : "Rent Now"}
                            </Button>
                          </div>
                        </div>
                      </CardContent>
                    </Card>
                  </div>
                ) : (
                  <div className="h-full flex items-center justify-center">
                    <div className="text-center p-10 bg-gradient-to-b from-gray-800 to-gray-700 rounded-xl border-2 border-dashed border-cyan-700 shadow-sm hover:shadow-md transition-all duration-300 transform hover:-translate-y-1">
                      <Car className="w-16 h-16 text-cyan-400 mx-auto mb-6 animate-pulse" />
                      <p className="text-cyan-300 rowdies-light text-xl leading-relaxed">
                        Select a vehicle from the list to view details and options
                      </p>
                      <p className="text-gray-400 poppins-regular text-sm mt-2">
                        Click on any vehicle card to get started
                      </p>
                    </div>
                  </div>
                )}

                <div className="pt-4 mt-4">
                  <Button
                    variant="outline"
                    className="w-full h-12 bg-[#282828] hover:bg-[#282828] text-white rowdies-bold rounded-lg transition-all duration-300 flex items-center justify-center gap-2"
                    onClick={returnVehicle}
                    disabled={loading}
                  >
                    {loading ? "Processing..." : "Return Vehicle"}
                    <ArrowRight className="h-5 w-5 animate-pulse" />
                  </Button>
                </div>
              </ScrollArea>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default RentalMenu;
